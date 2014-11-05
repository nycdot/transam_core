RSpec.configure do |config|
  puts "database_cleaner"
  DatabaseCleaner.strategy = :truncation, {:only => %w[assets asset_events asset_subtypes asset_types messages notices policies policy_items organizations organization_types users]}
  config.before(:suite) do
    begin
      DatabaseCleaner.start
    ensure
      DatabaseCleaner.clean
    end
  end
end