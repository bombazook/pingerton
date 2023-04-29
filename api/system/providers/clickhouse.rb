# frozen_string_literal: true

App.register_provider(:clickhouse) do
  prepare do
    require 'click_house'
    target.prepare :common
    ClickHouse.config do |config|
      config.logger = Logger.new($stdout) unless ENV['RACK_ENV'] == 'test'
      config.adapter = :net_http
      config.database = Config.new.clickhouse_db
      config.url = Config.new.clickhouse_url
      config.timeout = 60
      config.open_timeout = 3
      config.ssl_verify = false
      config.symbolize_keys = true
      config.headers = {}

      # if you want to add settings to all queries
      config.global_params = { mutations_sync: 1 }

      config.json_parser = ClickHouse::Middleware::ParseJsonOj
      config.json_serializer = ClickHouse::Serializer::JsonOjSerializer
    end
    register('clickhouse.pool', Tools::ConnectionPoolProxy.new { ClickHouse.connection })
  end
end
