if Rails.cache.is_a?(ActiveSupport::Cache::NullStore)
  # ActiveJob::Status.store = :mem_cache_store
  ActiveJob::Status.store = :redis_cache_store, { host: '127.0.0.1', port: 6379 }
end
# ActiveJob::Status.options = { includes: %i[status exception] }
ActiveJob::Status.options = { throttle_interval: 0 }