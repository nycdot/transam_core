CarrierWave.configure do |config|
  config.storage = :file
  config.root = "#{Rails.root}/public/uploads"
  config.cache_dir = "#{Rails.root}/tmp/uploads"
  config.base_path = "#{Rails.root}/public/uploads"
end
