# ENG-6: Migrate BigTrees from Ubuntu 16.04 EC2 to Ubuntu 24.04 + RDS

## Overview

Current production runs on a single EC2 instance (`50.17.61.15`) on Ubuntu 16.04 (EOL since April 2021) with a self-hosted MySQL 5.7.33. The host is too old to install Node 20 because Node 20 requires glibc ≥ 2.28 and Xenial ships glibc 2.23.

**Target state:**
- New EC2 instance running Ubuntu 24.04 LTS
- App-only roles: web + app (Passenger via nginx, solid_queue worker)
- RDS MySQL 8.0 (`db.t4g.micro`) replacing self-hosted MySQL
- Capistrano deploys from laptop; JS assets compiled locally and rsynced
- Existing AWS load balancer (or Elastic IP) re-pointed at the new instance for cutover
- Old box retained for ~1 week as rollback, then decommissioned

**Guiding constraints:**
- Single-operator deploy (laptop → AWS); no CI/CD pipeline in scope
- 15 users, low traffic — single-AZ RDS is acceptable
- DB import procedure must be **repeatable** so it can be rehearsed and re-run at cutover

## Pre-flight: Information to gather from the old server

The flow here is: **run one command on the old server that writes an audit file there**, then **scp that file (and the config files) back to a local migration folder**.

### Step 1: Make a local migration folder **(done)**
On your laptop:
```bash
mkdir -p ~/bigtrees-migration
cd ~/bigtrees-migration
```

### Step 2: SSH into the old server and run the audit **(done)**
SSH in:
```bash
ssh ubuntu@50.17.61.15
```

Once on the old server, run this single command to produce `~/audit.txt`:
```bash
{
  echo "=== OS ===";              lsb_release -a 2>/dev/null
  echo "=== Ruby ===";             ruby --version
  echo "=== Node ===";             node --version 2>/dev/null || echo "no node"
  echo "=== nginx ===";            nginx -v 2>&1
  echo "=== MySQL ===";            mysql --version
  echo "=== Passenger ===";        passenger --version 2>/dev/null || echo "no passenger in PATH"
  echo "=== Running services ==="; sudo systemctl list-units --type=service --state=running
  echo "=== Nginx status ===";     sudo systemctl status nginx --no-pager
  echo "=== MySQL status ===";     sudo systemctl status mysql --no-pager
  echo "=== Crontab ===";          crontab -l 2>/dev/null
  echo "=== /etc/cron.d ===";      sudo ls -la /etc/cron.d/
  echo "=== Disk usage (linked dirs) ==="
  sudo du -sh /var/www/bigtrees/shared/public/system 2>/dev/null
  sudo du -sh /var/www/bigtrees/shared/public/TreeImages 2>/dev/null
  sudo du -sh /var/www/bigtrees/shared/log 2>/dev/null
  echo "=== Certbot ===";          sudo certbot certificates 2>/dev/null || echo "no certbot"
  sudo ls /etc/letsencrypt/live/ 2>/dev/null
} > ~/audit.txt 2>&1
```

Also stage copies of the config files in your home directory so they're easy to `scp` (and so you don't need `sudo` over `scp`):
```bash
sudo cp /var/www/bigtrees/shared/config/application.yml ~/application.yml
sudo cp /var/www/bigtrees/shared/config/database.yml    ~/database.yml
sudo cp /etc/nginx/nginx.conf                           ~/nginx.conf
sudo cp /etc/nginx/sites-enabled/bigtrees               ~/nginx-site.conf 2>/dev/null \
  || sudo cp /etc/nginx/sites-available/bigtrees        ~/nginx-site.conf
sudo tar -czf ~/letsencrypt.tar.gz /etc/letsencrypt 2>/dev/null  # empty/missing if no certbot
sudo chown ubuntu:ubuntu ~/audit.txt ~/application.yml ~/database.yml ~/nginx.conf ~/nginx-site.conf ~/letsencrypt.tar.gz 2>/dev/null
```

Then exit back to your laptop:
```bash
exit
```

### Step 3: SCP everything back to the laptop **(done)**
From your laptop:
```bash
cd ~/bigtrees-migration

scp ubuntu@50.17.61.15:~/audit.txt           .
scp ubuntu@50.17.61.15:~/application.yml     .
scp ubuntu@50.17.61.15:~/database.yml        .
scp ubuntu@50.17.61.15:~/nginx.conf          .
scp ubuntu@50.17.61.15:~/nginx-site.conf     .
scp ubuntu@50.17.61.15:~/letsencrypt.tar.gz  .

chmod 600 application.yml database.yml
ls -la
```

You should now have everything you need in `~/bigtrees-migration/`. Read `audit.txt` and keep it handy throughout the migration.

### Step 4: Also gather from AWS console **(done)**
- Current EC2 instance type, VPC, subnet, security group IDs
- Whether traffic enters via ALB, NLB, CloudFront, or direct EIP → record the listener ARN(s)
- Route 53 records pointing at the domain (or external DNS provider)
- Current TLS cert (ACM ARN if behind ALB; Let's Encrypt on-host otherwise)

## Phase 1: Provision new EC2 instance

### 1.1 Snapshot the old box first **(done)**
- In EC2 console: Volumes → select old box's root volume → Actions → Create snapshot
- Tag: `bigtrees-pre-migration-YYYY-MM-DD`
- This is your "everything went wrong, restore" insurance

### 1.2 Launch new EC2 instance **(done)**

**Order of operations** — do steps 1.2a → 1.2c *before* opening the launch wizard, then run the wizard in 1.2d:
1. **1.2a** — Confirm VPC and subnet (recon, no changes)
2. **1.2b** — Create both security groups (the app SG must exist before launch so it can be attached; the RDS SG is created now too because it references the app SG)
3. **1.2c** — Verify or prepare the IAM role to attach
4. **1.2d** — Launch the EC2 instance, selecting the SG, subnet, key pair, and IAM role from steps above
5. **1.2e** — Optional SSM Session Manager setup

#### 1.2a Confirm VPC and subnet **(done)**
1. Look up the old box in EC2 console → Instances → click `i-...` (the old instance) → note **VPC ID** and **Subnet ID** on the Networking tab
2. Launch the new instance in the **same VPC**
3. **Subnet**: use the same subnet, or any subnet in the same VPC that is **public** (has a route to an internet gateway in its route table). The new box needs outbound internet to pull apt packages, fetch from GitHub, and reach S3/Nylas/Sentry
4. **Auto-assign public IPv4**: **Enable**. You'll need a public IP for SSH and for the ALB to reach the instance — unless your ALB is internal-only, in which case a private IP is fine

> RDS aside: RDS requires a "DB subnet group" containing subnets in **at least 2 different AZs**. If you launch the EC2 in a subnet whose AZ is the only AZ in your VPC with subnets, you may need to create another subnet in a different AZ before Phase 3. Easiest to check now: VPC → Subnets, filter by your VPC, confirm at least two AZs are represented.

#### 1.2b Security group setup **(done)**
Two security groups are involved. Create them now (the RDS one will be referenced in Phase 3):

**`bigtrees-app-sg`** (new — for the new EC2 instance):

| Direction | Protocol | Port | Source | Purpose |
|-----------|----------|------|--------|---------|
| Inbound   | TCP      | 22   | `<your-laptop-IP>/32` | SSH from you |
| Inbound   | TCP      | 80   | `<ALB-security-group-id>` | HTTP from ALB only |
| Inbound   | TCP      | 443  | `<ALB-security-group-id>` | HTTPS from ALB only (defense in depth even though ALB terminates TLS) |
| Outbound  | All      | All  | `0.0.0.0/0` | apt, git, S3, Nylas, Sentry, RDS |

To find the ALB security group ID: EC2 console → Load Balancers → click the ALB serving production → Security tab → copy the SG ID (looks like `sg-0abc123...`). Use the SG ID as the source, not the ALB's IP — that way the rule survives ALB IP changes.

To find your laptop's IP: `curl -s https://checkip.amazonaws.com` from your laptop. Use `<that-IP>/32` (the `/32` restricts it to exactly that one address). Re-run this if your home IP changes.

**`bigtrees-rds-sg`** (new — created here, attached to RDS in Phase 3.1):

| Direction | Protocol | Port | Source | Purpose |
|-----------|----------|------|--------|---------|
| Inbound   | TCP      | 3306 | `<bigtrees-app-sg id>` | MySQL from app instances only |
| Outbound  | All      | All  | `0.0.0.0/0` | (default; RDS doesn't initiate outbound but leave default) |

**What you should NOT do**:
- ❌ Allow port 80/443 from `0.0.0.0/0` on the app SG (bypasses the ALB, leaks the instance's public IP)
- ❌ Allow port 3306 from `0.0.0.0/0` on the RDS SG (huge attack surface)
- ❌ Allow SSH from `0.0.0.0/0` (use your IP, or set up Session Manager — see 1.2d)

#### 1.2c IAM instance role **(done)**
Check the old box's IAM role: EC2 → click old instance → Security tab → IAM Role. If there's a role attached, the new instance needs an equivalent one — most likely for:
- S3 access (uploads via `aws-sdk` or `fog-aws`)
- CloudWatch logs
- Possibly SSM (for Session Manager)

The simplest path: **attach the same IAM role to the new instance** in the launch wizard. (You can also attach it post-launch via EC2 → select instance → Actions → Security → Modify IAM role, but doing it at launch is one less step.)

If the old box had no IAM role and access keys are baked into `application.yml` instead, you can leave the new instance with no role for now. (Long-term, moving to IAM roles is better security hygiene, but not this migration's job.)

#### 1.2d Launch the instance **(done)**
Now open the EC2 launch wizard and fill in:
- **Name**: `bigtrees-app`
- **AMI**: Ubuntu Server 24.04 LTS (HVM), SSD, AMD64. Owner `099720109477` (Canonical). Search: `ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*`
- **Instance type**: `t3.small` (x86, consistent with the current `t3.medium`). 2 vCPU burstable, 2 GB RAM — plenty for 15 users. Can resize later with a few minutes of downtime.
- **Key pair**: reuse the same key pair the old box uses (so your existing `ssh-add` setup just works)
- **Network settings** → Edit:
  - **VPC**: the one identified in 1.2a
  - **Subnet**: a public subnet in that VPC
  - **Auto-assign public IP**: Enable
  - **Firewall (security groups)**: **Select existing** → pick `bigtrees-app-sg` from 1.2b
- **Storage**: 30 GB gp3 root volume, default IOPS (3000) and throughput (125 MB/s)
- **Advanced details → IAM instance profile**: select the role identified in 1.2c (or leave blank if none)
- **User data**: leave empty — we provision manually in Phase 2

Click Launch. Note the instance's public IP / public DNS once it's running — you'll use it for SSH and to register with the ALB target group in Phase 7.1.

#### 1.2e Optional: enable SSM Session Manager **(skipped — optional)**
A nice quality-of-life improvement — lets you "SSH" to the box through the AWS console without exposing port 22 publicly:
1. Attach the AWS-managed `AmazonSSMManagedInstanceCore` policy to the instance's IAM role
2. The SSM Agent is pre-installed on Ubuntu Server 24.04 AMIs
3. You can then connect via EC2 → Connect → Session Manager, no SSH key or open port needed
4. If you adopt this, you can eventually remove the inbound 22 rule from `bigtrees-app-sg`

### 1.3 Initial connectivity **(done)**
```bash
ssh ubuntu@98.93.41.206
sudo apt-get update && sudo apt-get upgrade -y
sudo reboot
```

### 1.4 Set hostname **(done)**
```bash
sudo hostnamectl set-hostname bigtrees-app
echo "127.0.1.1 bigtrees-app" | sudo tee -a /etc/hosts
```

## Phase 2: Bootstrap the new server (no app deploy yet)

All commands run as `ubuntu` on the new instance unless noted.

### 2.1 Base packages **(done)**
```bash
sudo apt-get install -y \
  build-essential git curl wget \
  libssl-dev libreadline-dev zlib1g-dev libyaml-dev libxml2-dev libxslt1-dev \
  libcurl4-openssl-dev libffi-dev libgmp-dev \
  libmysqlclient-dev mysql-client \
  libvips imagemagick \
  pkg-config autoconf bison \
  htop tmux ufw fail2ban \
  unzip
```
Notes:
- `mysql-client` only (no server — MySQL is on RDS)
- `libvips` and `imagemagick` for image processing in the app
- `wkhtmltopdf` is needed for `wicked_pdf`; install separately if used:
  ```bash
  sudo apt-get install -y wkhtmltopdf
  ```
  Verify by checking `Gemfile` for `wicked_pdf` and the binary path in production config.

### 2.2 Install rbenv + Ruby 3.3.1 **(done)**
```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

rbenv install 3.3.1
rbenv global 3.3.1
ruby --version  # confirm 3.3.1

gem install bundler --no-document
```

### 2.3 Install Node 20 **(done)**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Yarn (Webpacker uses yarn)
sudo npm install -g yarn

node --version  # v20.x
yarn --version
```

### 2.4 Install Passenger + nginx **(done)**
The app uses Phusion Passenger (per `Capfile`). Use the official Passenger nginx module from their apt repo:
```bash
sudo apt-get install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common
curl https://oss-binaries.phusionpassenger.com/auto-software-signing-gpg-key.txt | sudo gpg --dearmor -o /etc/apt/keyrings/phusion.gpg
sudo sh -c 'echo "deb [signed-by=/etc/apt/keyrings/phusion.gpg] https://oss-binaries.phusionpassenger.com/apt/passenger noble main" > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update
sudo apt-get install -y nginx libnginx-mod-http-passenger

# Verify passenger module loaded
sudo passenger-config validate-install
sudo /usr/sbin/nginx -V 2>&1 | grep -o 'with-cc-opt.*passenger'
```

Configure passenger to use the rbenv-managed Ruby:
```bash
which ruby  # should be ~/.rbenv/shims/ruby — but passenger needs the resolved path
rbenv which ruby  # /home/ubuntu/.rbenv/versions/3.3.1/bin/ruby
```
Edit `/etc/nginx/conf.d/mod-http-passenger.conf` (or wherever passenger config landed):
```nginx
passenger_ruby /home/ubuntu/.rbenv/versions/3.3.1/bin/ruby;
```

### 2.5 nginx site config **(done)**
TLS is terminated at the ALB (confirmed in pre-flight), so this nginx only listens on port 80. The ALB sets `X-Forwarded-Proto`, which we use to redirect any non-HTTPS hits, and exposes `/health` for the ALB health check.

Place at `/etc/nginx/sites-available/bigtrees`:
```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name bigtreeservices.com;

    root /var/www/bigtrees/current/public;
    passenger_app_root /var/www/bigtrees/current;
    passenger_app_env production;
    passenger_min_instances 1;

    client_max_body_size 200M;

    # ALB health check — never redirect
    location ~ ^/health$ {
        passenger_enabled on;
        break;
    }

    location / {
        if ($http_x_forwarded_proto != "https") {
            return 301 https://$host$request_uri;
        }
        passenger_enabled on;
    }

    location ~ ^/(packs|assets)/ {
        gzip_static on;
        expires max;
        add_header Cache-Control public;
    }

    location ~ /\.(?!well-known) { deny all; }
}
```
Enable and reload:
```bash
sudo ln -sf /etc/nginx/sites-available/bigtrees /etc/nginx/sites-enabled/bigtrees
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

### 2.6 Create deploy directory structure **(done)**
Capistrano expects `:deploy_to` (`/var/www/bigtrees`) to exist and be writable by the deploy user.
```bash
sudo mkdir -p /var/www/bigtrees
sudo chown ubuntu:ubuntu /var/www/bigtrees
mkdir -p /var/www/bigtrees/shared/config
mkdir -p /var/www/bigtrees/shared/log
mkdir -p /var/www/bigtrees/shared/tmp/{pids,cache,sockets,locks}
mkdir -p /var/www/bigtrees/shared/public/{system,TreeImages,packs,assets}
```

### 2.7 Firewall basics **(done)**
```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable
sudo ufw status
```

### 2.8 systemd unit for solid_queue **(done)**
Create `/etc/systemd/system/bigtrees-solid-queue.service`:
```ini
[Unit]
Description=Solid Queue worker for BigTrees
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/var/www/bigtrees/current
Environment=RAILS_ENV=production
ExecStart=/home/ubuntu/.rbenv/shims/bundle exec rake solid_queue:start
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```
Don't enable yet — wait until after first deploy so `/var/www/bigtrees/current` exists.

### 2.9 Snapshot the bootstrapped instance **(done)**
Take an EBS snapshot of the new instance's volume now. This is a "clean bootstrap" rollback point — if you mess up the app deploy you can restore to this rather than re-running Phase 2.

## Phase 3: Provision RDS MySQL 8.0

### 3.1 Create the RDS instance **(done)**
- Engine: **MySQL 8.0** (latest minor)
- Templates: Production (still cheap — just gives you sensible defaults)
- DB instance identifier: `bigtrees-prod`
- Master username: `bigtrees_admin` (avoid `root` or `admin`)
- Master password: generate, save to 1Password
- Instance class: `db.t4g.micro`
- Storage: 20 GB gp3, **enable storage autoscaling** up to 50 GB
- VPC: same as EC2
- **Public access: No**
- VPC security group: create new `bigtrees-rds-sg` allowing inbound 3306 from `bigtrees-app-sg` only
- Initial database name: `bigtrees` (matches the existing prod DB name — see pre-flight `database.yml`)
- Backups: 7-day retention
- Maintenance window: pick a low-traffic hour
- Deletion protection: **On**
- Auto minor version upgrade: On

> Note: the old production server connects to MySQL as `root` with a weak password (per pre-flight `database.yml`). Migrating to a dedicated, less-privileged `bigtrees_app` user on RDS (step 3.3) is an intentional security improvement.

### 3.2 Connectivity test from EC2 **(done)**
```bash
# On new EC2
mysql -h bigtrees-prod.xxxxx.us-east-1.rds.amazonaws.com \
      -u bigtrees_admin -p \
      -e "SHOW DATABASES;"
```
If this fails: check security group rules, that the EC2 instance is in the same VPC, and that RDS is in an "available" state.

### 3.3 Create an application user (less privileged than master) **(done)**

Run this from the **new EC2** (the RDS security group only allows 3306 from `bigtrees-app-sg`, so your laptop can't connect directly). Open an interactive mysql session as the master user:

```bash
# On new EC2
mysql -h bigtrees-prod.xxxxx.us-east-1.rds.amazonaws.com \
      -u bigtrees_admin -p
# Enter the master password from 3.1 when prompted.
# You should see a `mysql>` prompt.
```

Then at the `mysql>` prompt, paste:

```sql
CREATE USER 'bigtrees_app'@'%' IDENTIFIED BY '<strong-password>';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, REFERENCES,
      CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE,
      CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, TRIGGER
  ON bigtrees.* TO 'bigtrees_app'@'%';
FLUSH PRIVILEGES;
EXIT;
```

Save this password — it goes in `database.yml`.

> The `mysql` client comes from the `mysql-client` apt package installed in Phase 2.3 (line 209). If `mysql: command not found`, that package didn't install — go back and `sudo apt install mysql-client`.

## Phase 4: Repeatable DB migration procedure

This procedure is designed to be run multiple times (rehearsals, then cutover). Each run starts from a clean dump and loads into a fresh database.

### 4.1 Take a dump from the old server **(done)**
```bash
# On old server (50.17.61.15)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
mysqldump -u root -p \
  --single-transaction \
  --routines \
  --triggers \
  --set-gtid-purged=OFF \
  --default-character-set=utf8mb4 \
  --column-statistics=0 \
  bigtrees > ~/bigtrees-dump-${TIMESTAMP}.sql

gzip ~/bigtrees-dump-${TIMESTAMP}.sql
ls -lh ~/bigtrees-dump-${TIMESTAMP}.sql.gz
```

### 4.2 Transfer dump to new EC2 **(done)**
```bash
# From laptop (or directly old → new with scp -3)
scp ubuntu@50.17.61.15:~/bigtrees-dump-${TIMESTAMP}.sql.gz /tmp/
scp /tmp/bigtrees-dump-${TIMESTAMP}.sql.gz ubuntu@98.93.41.206:~/
```
Or, if the old box has the new EC2's SSH key:
```bash
# On old server
scp ~/bigtrees-dump-${TIMESTAMP}.sql.gz ubuntu@98.93.41.206:~/
```

### 4.3 Reset RDS database (idempotent — run before each import) **(done)**
```bash
# On new EC2
mysql -h <rds-endpoint> -u bigtrees_admin -p <<'SQL'
DROP DATABASE IF EXISTS bigtrees;
CREATE DATABASE bigtrees CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SQL
```

### 4.4 Load dump into RDS **(done)**
```bash
# On new EC2
gunzip -k ~/bigtrees-dump-${TIMESTAMP}.sql.gz

time mysql -h <rds-endpoint> \
      -u bigtrees_admin -p \
      bigtrees < ~/bigtrees-dump-${TIMESTAMP}.sql
```
For a 20 GB DB this typically takes 10–30 minutes depending on schema complexity.

### 4.5 Validate the import **(done)**
```bash
mysql -h <rds-endpoint> -u bigtrees_admin -p bigtrees <<'SQL'
SELECT
  (SELECT COUNT(*) FROM estimates) AS estimates,
  (SELECT COUNT(*) FROM arborists) AS arborists,
  (SELECT COUNT(*) FROM organizations) AS organizations,
  (SELECT COUNT(*) FROM trees) AS trees;

-- Spot-check schema parity
SHOW TABLES;
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'bigtrees';
SQL
```
Compare against the same queries run on the old DB. Counts should match exactly (if no writes happened between dump and check).

### 4.6 Script it **(done)**
Save this as `~/import-prod-db.sh` on the new EC2 so it's repeatable:
```bash
#!/usr/bin/env bash
set -euo pipefail

DUMP_FILE="${1:?Usage: $0 <path-to-dump.sql.gz>}"
RDS_HOST="bigtrees-prod.xxxxx.us-east-1.rds.amazonaws.com"
RDS_USER="bigtrees_admin"

echo "==> Decompressing dump..."
gunzip -kf "$DUMP_FILE"
SQL_FILE="${DUMP_FILE%.gz}"

echo "==> Dropping and recreating bigtrees..."
mysql -h "$RDS_HOST" -u "$RDS_USER" -p <<SQL
DROP DATABASE IF EXISTS bigtrees;
CREATE DATABASE bigtrees CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SQL

echo "==> Importing dump (this may take a while)..."
time mysql -h "$RDS_HOST" -u "$RDS_USER" -p bigtrees < "$SQL_FILE"

echo "==> Done. Validating..."
mysql -h "$RDS_HOST" -u "$RDS_USER" -p bigtrees -e \
  "SELECT 'estimates' AS table_name, COUNT(*) AS row_count FROM estimates
   UNION SELECT 'arborists', COUNT(*) FROM arborists
   UNION SELECT 'organizations', COUNT(*) FROM organizations;"
```
Make executable: `chmod +x ~/import-prod-db.sh`

### 4.7 User-uploaded files **(done)**
Pre-flight confirmed `public/system` and `public/TreeImages` on the old box are both **4 KB** (empty directories), so all user uploads are already on S3. Nothing to migrate here — the empty linked dirs created in step 2.6 are enough for the symlinks Capistrano expects.

## Phase 5: Capistrano configuration updates

All edits happen on your **laptop**, committed to the repo.

### 5.1 Move server definition out of `deploy.rb` into stages **(done)**
Current `config/deploy.rb` line 4 hardcodes the old server. Remove it; define stage-specific servers.

**`config/deploy.rb`** — delete the `server '50.17.61.15', ...` line.

**`config/deploy/production.rb`** — add at top:
```ruby
server '98.93.41.206',
       port: 22,
       user: 'ubuntu',
       roles: [:web, :app, :db],
       primary: true
```
The `:db` role is kept on the app server — it doesn't mean "MySQL lives here," it means "run `cap deploy:migrate` from here" (which then connects to RDS via Rails). If no server has `:db`, capistrano-rails silently skips migrations. With multiple app servers, `primary: true` + `:db` ensures exactly one runs migrations.

**`config/deploy/staging.rb`** — (optional safety net) point at old box during transition:
```ruby
server '50.17.61.15', port: 22, user: 'ubuntu', roles: [:web, :app, :db], primary: true
```
This lets you still `cap staging deploy` to the old box if you need to ship a hotfix mid-migration.

### 5.2 Create shared linked files on new server **(done)**
The first deploy will fail if these don't exist. You already pulled them from the old box during pre-flight (`~/bigtrees-migration/application.yml` and `database.yml`). Copy them so you can edit the new versions without losing the originals:
```bash
cd ~/bigtrees-migration
cp database.yml database.yml.NEW
$EDITOR database.yml.NEW
```
Update `database.yml.NEW` so the production section looks like:
```yaml
production:
  adapter: mysql2
  encoding: utf8mb4
  collation: utf8mb4_unicode_ci
  database: bigtrees
  username: bigtrees_app
  password: <password-from-3.3>
  host: bigtrees-prod.xxxxx.us-east-1.rds.amazonaws.com
  port: 3306
  pool: 10
  reconnect: true
```
`application.yml` carries over unchanged. Upload both to the new server:
```bash
scp application.yml      ubuntu@98.93.41.206:/var/www/bigtrees/shared/config/application.yml
scp database.yml     ubuntu@98.93.41.206:/var/www/bigtrees/shared/config/database.yml
ssh ubuntu@98.93.41.206 'chmod 600 /var/www/bigtrees/shared/config/*.yml'
```

### 5.3 Local asset precompile (optional, recommended) **(done)**
Add to `Gemfile`:
```ruby
group :development do
  gem 'capistrano-local-precompile', require: false
end
```
Add to `Capfile`:
```ruby
require 'capistrano/local_precompile'
```
This compiles assets on your laptop and rsyncs them — keeps memory pressure off the t3.small.

### 5.4 SSH access for Capistrano
Your laptop's SSH key needs to be in `/home/ubuntu/.ssh/authorized_keys` on the new server. If you launched the EC2 with the same key pair, this is already done. Verify:
```bash
ssh ubuntu@98.93.41.206 "cat ~/.ssh/authorized_keys"
```
Also: GitHub access. Capistrano pulls from `git@github.com:RobStaalduinen/bigtrees.git` on the deploy host. Either:
- Add a read-only deploy key on the new server's `~/.ssh/id_ed25519.pub` to the GitHub repo's Deploy Keys, OR
- Use SSH agent forwarding (`ssh -A`) — Capistrano supports this via `set :ssh_options, forward_agent: true` (already the default)

Test from new server:
```bash
ssh -T git@github.com  # should print "Hi RobStaalduinen!"
```

### 5.5 Pre-flight: bundle binstubs and webpacker locally
Make sure local Node/Yarn versions match what the app expects (`package.json` `engines` field, if set). Then:
```bash
# Laptop
bundle install
yarn install
bundle exec rails assets:precompile RAILS_ENV=production  # smoke test
```

## Phase 6: First deploy and smoke test

### 6.1 Deploy
```bash
# Laptop, in repo root
cap production deploy
```
Watch for:
- SSH connection to new server succeeds
- Git clone/fetch succeeds
- `bundle install` runs on new server
- `assets:precompile` runs (locally if Phase 5.3 done, remotely otherwise)
- Migrations run (should be no-ops since DB was just imported)
- Symlinks created in `current`
- Passenger restart

If anything fails, the error is usually clear. Common gotchas:
- Missing native gem dependencies → `apt-get install` the relevant `-dev` package
- `database.yml` permissions wrong → must be readable by `ubuntu`
- nginx/passenger not seeing the right Ruby → re-check `passenger_ruby` directive

### 6.2 Verify the app boots
```bash
# On new server
cd /var/www/bigtrees/current
RAILS_ENV=production bundle exec rails runner "puts 'DB OK: ' + Estimate.count.to_s"
```

### 6.3 Hit the app directly
Add a temporary entry to your laptop's `/etc/hosts` so you can browse the new app under its real domain without touching DNS:
```
98.93.41.206  bigtreeservices.com
```
Note: the nginx config redirects to HTTPS unless `X-Forwarded-Proto: https` is set. Since you're hitting it directly (not via the ALB), either:
- Test through the ALB target group (registered but not yet receiving live traffic) — simplest, exercises the production-like path, or
- Temporarily comment out the HTTPS redirect block in `/etc/nginx/sites-enabled/bigtrees` during smoke testing
Then load the site in your browser and:
- Log in
- Open a few estimates
- Try uploading a tree image
- Generate a PDF (wicked_pdf)
- Trigger a background job and check solid_queue picked it up
- Try an Excel report

Remove the `/etc/hosts` entry when done.

### 6.4 Enable solid_queue service
```bash
sudo systemctl daemon-reload
sudo systemctl enable bigtrees-solid-queue
sudo systemctl start bigtrees-solid-queue
sudo systemctl status bigtrees-solid-queue
journalctl -u bigtrees-solid-queue -f  # tail logs
```

### 6.5 Set up whenever cron
```bash
# On new server
cd /var/www/bigtrees/current
bundle exec whenever --update-crontab --set environment=production
crontab -l  # verify
```

## Phase 7: Cutover (ALB target group swap)

Pre-flight confirmed TLS is terminated at an ALB (no certbot on old box; nginx uses `X-Forwarded-Proto`). Cutover is therefore an ALB target-group swap — fast, reversible, and DNS-free.

### 7.1 Set up the new target group ahead of time
Can be done days before cutover with zero impact to production:
1. Create a new target group: `bigtrees-app-tg`, target type `instance`, protocol HTTP, port 80
2. Health check path: `/health` (matches the location block in the new nginx config)
3. Register the new EC2 instance in the new target group
4. Wait for health check to show `healthy` — if not, debug nginx/passenger on the new box before going further
5. The ALB still routes 100% to the old target group; new box receives no live traffic yet

### 7.2 Pre-cutover checklist
- [ ] Final DB dump taken from old box (Phase 4.1)
- [ ] DB imported into RDS (Phase 4.3–4.5)
- [ ] App smoke-tested via `/etc/hosts` override (Phase 6.3)
- [ ] solid_queue running (Phase 6.4)
- [ ] cron installed (Phase 6.5)
- [ ] Sentry/error tracking confirmed reporting from new box
- [ ] Backups verified: RDS automatic backups visible in console
- [ ] New target group reports `healthy` for the new instance
- [ ] Brief maintenance window announced to users
- [ ] Old box put in "read-only" / maintenance mode (Capistrano `maintenance:enable`) to prevent split-brain writes

### 7.3 Perform the swap
1. Put the old box in maintenance mode: `cap production maintenance:enable` (or whatever the existing maintenance task is)
2. Take the final DB dump and import into RDS (Phase 4 procedure — the import script makes this ~15 minutes)
3. In the ALB console: edit the production listener rule(s) → change the forward action from the old target group to `bigtrees-app-tg`
4. Save — traffic switches immediately
5. Watch CloudWatch ALB metrics and Sentry for the first few minutes

### 7.2 Minimize delta between final dump and cutover
The DB on the old server may receive writes between when you take the final dump and when you switch traffic. Options:
- **Brief downtime**: announce maintenance window, put old app in maintenance mode (`cap production maintenance:enable` if `capistrano/maintenance` supports it), take final dump, import, cut over. Best for small user base — ~30 min outage.
- **Read replica trick**: more complex; out of scope for 15 users.

For 15 users, a **30-minute scheduled downtime is the simplest, safest path**.

## Phase 8: Post-cutover validation

Within the first hour after cutover:
- [ ] Hit the production URL in a browser, log in
- [ ] Have a real user try an end-to-end estimate flow
- [ ] Trigger a job that hits Nylas (email)
- [ ] Trigger a job that writes to S3
- [ ] Check Sentry for new errors
- [ ] Check CloudWatch RDS metrics: connections, CPU, IOPS — should be very low
- [ ] Verify automated backup ran (RDS console → Maintenance & backups)
- [ ] `journalctl -u solid_queue -n 200` — no errors
- [ ] `sudo tail -f /var/log/nginx/error.log` — no errors

Over the first week:
- [ ] Monitor RDS storage growth — confirm autoscaling threshold is sane
- [ ] Watch CPU credit balance on t3.small (CloudWatch metric `CPUCreditBalance`) — should stay near max if under-utilized
- [ ] Verify nightly whenever jobs run

## Phase 9: Decommission old infrastructure

**Wait at least 1 week** of stable operation before decommissioning. Keep rollback intact until you're confident.

When ready:
1. Final snapshot of old EBS volume (already done in Phase 1.1, but take another current one)
2. Stop the old EC2 instance (don't terminate yet)
3. Wait another week
4. Terminate the old EC2 instance
5. Delete the old security group(s) if not shared
6. Release the old Elastic IP (if applicable and no longer attached)
7. Update internal docs / CLAUDE.md with new server details

## Rollback procedures

### During Phase 1–6 (before traffic cutover)
- No rollback needed; old box is still serving traffic
- Just fix-forward or destroy and re-provision the new instance

### During Phase 7 cutover, if smoke test fails
- Revert the ALB listener rule back to the old target group — traffic returns to the old box immediately
- The old MySQL on the old box has kept running and is still authoritative; RDS data may be stale but no writes were lost since users were in maintenance mode

### Post-cutover, if a critical issue emerges
1. Put new box in maintenance mode
2. Take a dump of RDS (captures any writes that happened since cutover)
3. Revert the ALB listener back to the old target group
4. Decide whether to merge the diff back into old MySQL or accept data loss
5. Diagnose new-box issue, fix, retry

## Pre-flight findings (already confirmed)

- ✅ Old box: Ubuntu 16.04.5, Ruby 3.3.1, nginx 1.18, MySQL 5.7.33, Passenger 6.0.6, no node
- ✅ Uploads are on S3 (`public/system` and `public/TreeImages` are empty) — Phase 4.7 is a no-op
- ✅ TLS terminates at the ALB (no certbot, nginx redirects via `X-Forwarded-Proto`) — Phase 7 = ALB target group swap
- ✅ Production DB name is `bigtrees` (not `bigtrees_production`); user is `root` (will move to `bigtrees_app` on RDS)
- ✅ Background jobs: delayed_job entry in crontab is a stale holdover from a removed setup; solid_queue is the path forward — current plan is correct
- ✅ Production server_name: `bigtreeservices.com`
- ✅ nginx `client_max_body_size`: 200M (matched in new config)
- ✅ ALB health check endpoint: `/health`

## Open questions to confirm before starting

- [ ] Confirm whether `wkhtmltopdf` is actually used (check Gemfile)
- [ ] Confirm any IAM roles / instance profiles the old box uses (S3, Sentry source maps, etc.) — need to attach equivalent role on new EC2
- [ ] Confirm time of low-traffic window for cutover

## Estimated timeline

- **Phase 1–2** (provision + bootstrap): 2–3 hours, can be done any time
- **Phase 3** (RDS): 30 minutes provisioning + waiting for instance ready
- **Phase 4** (DB migration rehearsal): 1 hour first time, 15–30 min on subsequent runs
- **Phase 5** (Capistrano config): 30 minutes
- **Phase 6** (first deploy + smoke test): 1–2 hours
- **Phase 7** (cutover): 30 minutes of actual downtime, scheduled
- **Phase 8–9** (validation + decommission): 1–2 weeks of monitoring, ~30 minutes of actual work

Total: ~1 working day of focused effort spread across a week or two.
