# /var/www/strivo/config/puma.rb
directory "/var/www/strivo"
environment ENV.fetch("RAILS_ENV","production")

threads_count = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
threads threads_count, threads_count
workers Integer(ENV.fetch("WEB_CONCURRENCY", 2))
preload_app!

pidfile "/var/www/strivo/tmp/pids/puma.pid"
state_path "/var/www/strivo/tmp/pids/puma.state"

# Belangrijk: TCP bind voor Nginx proxy

stdout_redirect "/var/www/strivo/log/puma.stdout.log", "/var/www/strivo/log/puma.stderr.log", true

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection_pool.disconnect! rescue nil
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
# --- systemd-safe defaults ---
bind "tcp://127.0.0.1:3000"
