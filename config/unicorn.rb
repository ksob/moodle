require 'sidekiq'

worker_processes 3

before_fork do |server, worker|
   @sidekiq_pid ||= spawn("bundle exec sidekiq -c 1")
end


after_fork do |server, worker|
  Sidekiq.configure_client do |config|
    config.redis = { :size => 1 }
  end
  Sidekiq.configure_server do |config|
    config.redis = { :size => 5 }
  end
end
