# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start do
  add_filter %r{^/spec/}
end

require_relative '../system/boot'
require 'database_cleaner/redis'
require 'anyway/testing/helpers'

DatabaseCleaner[:redis].db = Config.new.redis_url
DatabaseCleaner[:redis].strategy = :deletion

RSpec.configure do |config|
  config.include Anyway::Testing::Helpers
  config.disable_monkey_patching!

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.before(:each, truncate_click_house: true) do
    ClickHouse.connection.truncate_tables
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.order = :random
  Kernel.srand config.seed
end
