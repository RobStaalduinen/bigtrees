# Deploy checklist — Rails 6 → 8 + Solid Queue

Pre-deploy operational steps for the EC2 production server. Most of these are
one-time setup; the rest are per-deploy state checks for the first deploy of
this branch only.

## One-time server prep — must complete BEFORE first deploy

### 1. Solid Queue systemd unit

Without this file, `cap solid_queue:restart` (auto-fired after
`deploy:publishing`) will fail and the worker will not run.

Create `/etc/systemd/system/bigtrees-solid-queue.service`:

```ini
[Unit]
Description=BigTrees Solid Queue worker
After=network.target mysql.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/var/www/bigtrees/current
Environment=RAILS_ENV=production
Environment=PATH=/home/ubuntu/.rbenv/shims:/home/ubuntu/.rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=/home/ubuntu/.rbenv/shims/bundle exec bin/jobs
Restart=always
RestartSec=5
KillMode=mixed
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
```

Then:

```bash
sudo systemctl daemon-reload
```

**Do NOT start it yet.** `bin/jobs` does not exist until the deploy puts it
there. The first deploy will start it via the Capistrano task.

### 2. Sudoers entry for the deploy user

The Capistrano task runs `sudo systemctl restart bigtrees-solid-queue` on every
deploy and will hang on a password prompt without this. Use `sudo visudo -f` to
avoid locking yourself out:

```bash
sudo visudo -f /etc/sudoers.d/bigtrees-solid-queue
```

Contents:

```
ubuntu ALL=(ALL) NOPASSWD: /bin/systemctl start bigtrees-solid-queue, /bin/systemctl stop bigtrees-solid-queue, /bin/systemctl restart bigtrees-solid-queue, /bin/systemctl status bigtrees-solid-queue
```

Note: the path may be `/usr/bin/systemctl` on some Ubuntus — confirm with
`which systemctl` on the box and adjust.

### 3. Confirm Node version

Shakapacker / Webpack 5 requires Node ≥14. Check on the box:

```bash
node -v
```

If <14 (or if Capistrano-npm picks up a different Node than your interactive
shell), asset precompile will fail. Symlink `/usr/local/bin/node` to the
desired Node binary if interactive shell vs. login shell pick up different
versions via nvm.

### 4. Confirm Ruby and native build deps

```bash
rbenv versions          # 3.3.1 must be present
which gcc && which make # native gem rebuilds (mini_racer, nokogiri) need these
```

### 5. Confirm MySQL privileges

The new migration creates 11 Solid Queue tables with foreign keys. The DB user
needs `CREATE`, `ALTER`, `INDEX`, and `REFERENCES`. If the original grant was
narrowly scoped, widen it:

```sql
SHOW GRANTS FOR 'bigtrees'@'%';
```

## Pre-deploy state — for the first deploy of this branch only

### 6. Drain delayed_job and stop the worker

The current release still runs delayed_job. The 3-hour cron will otherwise
resurrect it mid-deploy. From the deploy user's shell on the box:

```bash
cd /var/www/bigtrees/current
RAILS_ENV=production bundle exec bin/delayed_job stop
RAILS_ENV=production bundle exec rails runner 'puts Delayed::Job.count'
```

`Delayed::Job.count` must be `0` before proceeding.

## Deploy

From your laptop:

```bash
bundle exec cap production deploy
```

Watch for failures during:
- `bundle install --deployment` — native gem rebuilds for `mini_racer`, `nokogiri`
- `assets:precompile` — Shakapacker / webpack 5 build (needs Node ≥14)
- `db:migrate` — applies `CreateSolidQueueTables` (11 tables)
- `solid_queue:restart` (post-publish hook) — needs the systemd unit and
  sudoers entry from steps 1 and 2

## Post-deploy verification

```bash
# Enable the unit so it survives reboots
sudo systemctl enable bigtrees-solid-queue

# Confirm worker is running
sudo systemctl status bigtrees-solid-queue   # expect "active (running)"

# Tail logs for ~5 minutes — watch for boot errors and any exception loop
sudo journalctl -u bigtrees-solid-queue -f
```

In a `rails console` (or via the database directly):

```ruby
SolidQueue::Process.count   # should be > 0 — the supervisor + worker each register a row
SolidQueue::Process.last    # last_heartbeat_at should be very recent
```

Crontab should now be empty of bigtrees-specific jobs (the old 3-hour DJ
restart line is gone, and `config/schedule.rb` defines no replacement):

```bash
crontab -l   # only whenever's BEGIN/END markers expected
```

## Known one-time effects on first deploy

These are user-visible side effects of the Rails 7.0 framework defaults flip
that already shipped earlier in the upgrade. Not blockers, just things to
expect:

- **Every logged-in user gets logged out.** SHA1→SHA256 key generator
  invalidates all existing signed/encrypted cookies. Don't deploy right after a
  password-reset email blast — those links will also be invalid.
- **First page-load per client is a one-time miss** as ETags rotate.
- **Any in-flight CSRF token** at the moment of deploy may briefly mismatch on
  form submit — resolves on the next page load.

## Rollback path

If Solid Queue misbehaves, the revert is a one-line change to
`config/application.rb` plus restarting delayed_job from the still-present
binstub:

```ruby
# config/application.rb
config.active_job.queue_adapter = :delayed_job   # was: :solid_queue
```

Then on the server:

```bash
sudo systemctl stop bigtrees-solid-queue
cd /var/www/bigtrees/current
RAILS_ENV=production bundle exec bin/delayed_job start
```

`delayed_job_active_record`, `daemons`, `bin/delayed_job`, and the
`delayed_jobs` table all remain in place specifically for this purpose. They
are removed in step 8 of the upgrade plan, only after Solid Queue has soaked
for ≥7 days in production.
