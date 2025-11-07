# frozen_string_literal: true

app_root = File.expand_path("..", __dir__)
environment "production"

# Threads/workers
threads_count = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
threads threads_count, threads_count
workers Integer(ENV.fetch("WEB_CONCURRENCY", 2))

preload_app!

# Bind op TCP (matcht je logs en is simpel met Nginx)
bind "tcp://127.0.0.1:3000"

# PID/state (optioneel maar netjes)
pidfile File.join(app_root, "tmp/pids/puma.pid")
state_path File.join(app_root, "tmp/pids/puma.state")

# Graceful timeouts
worker_timeout 60 if ENV["RAILS_ENV"] == "development"
worker_shutdown_timeout 30

before_worker_boot do
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

plugin :tmp_restart