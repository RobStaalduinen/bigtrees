namespace :solid_queue do
  desc "Restart the Solid Queue worker process via systemd"
  task :restart do
    on roles(:app) do
      execute :sudo, "systemctl restart bigtrees-solid-queue"
    end
  end

  desc "Start the Solid Queue worker process via systemd"
  task :start do
    on roles(:app) do
      execute :sudo, "systemctl start bigtrees-solid-queue"
    end
  end

  desc "Stop the Solid Queue worker process via systemd"
  task :stop do
    on roles(:app) do
      execute :sudo, "systemctl stop bigtrees-solid-queue"
    end
  end

  desc "Show Solid Queue worker process status"
  task :status do
    on roles(:app) do
      execute :sudo, "systemctl status bigtrees-solid-queue", raise_on_non_zero_exit: false
    end
  end
end
