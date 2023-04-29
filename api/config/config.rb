# frozen_string_literal: true

class Config < Anyway::Config
  config_name :pingerton
  attr_config :clickhouse_url, :clickhouse_db, :redis_url, timeout: 1000, period: 2000
end
