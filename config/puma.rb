# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies that the worker count should be equal to the number of processors
# available to the application.
#
# By default, Puma will use all available processors on the machine.
# Setting this to a smaller number can be useful for development or testing.
#
# In development, this is set to 1 to avoid spawning multiple workers unnecessarily.
if ENV["RAILS_ENV"] == "development"
  # Preload app before forking workers
  # preload_app!

  # No workers in development mode
else
  # Production workers
  # workers ENV.fetch("WEB_CONCURRENCY") { 2 }
end

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart
