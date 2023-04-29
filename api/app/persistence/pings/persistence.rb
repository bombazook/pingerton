# frozen_string_literal: true

module Pings
  class Persistence
    KEY = 'pings'
    TIMEOUT_KEY_BASE = 'pings.timeout'
    include Import['redis.pool', 'config', 'redis.lua_cache']

    def create(address, sequence: 0, time: Time.now, timeout: config.timeout)
      data = JSON.dump({ sequence:, time: time.to_f })
      result = lua_cache.eval('pings/create', keys: [KEY, timeout_key(address)],
                                              argv: [address, data, timeout, sequence])
      parse_data(result[1..]).merge(status: result[0])
    end

    def destroy(address, sequence: -1)
      result = lua_cache.eval('pings/destroy', keys: [KEY, timeout_key(address)], argv: [address, sequence])
      parse_data(result[1..].compact).merge(status: result[0])
    end

    private

    def parse_data(data)
      return { data: data[0] } if data[0].is_a? Integer

      parsed_data = data.map { |i| i && JSON.parse(i).transform_keys(&:to_sym) }
      return { data: parsed_data[0] } if parsed_data.size < 2

      { data: parsed_data[0], expired_data: parsed_data[1] }
    end

    def timeout_key(address)
      [TIMEOUT_KEY_BASE, address].join('.')
    end
  end
end
