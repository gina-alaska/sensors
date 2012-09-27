Sidekiq.configure_server do |config|
  config.redis = { :url => 'redis://hermes.gina.alaska.edu:6379/12', :namespace => 'amaru' }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => 'redis://hermes.gina.alaska.edu:6379/12', :namespace => 'amaru', :size => 1 }
end