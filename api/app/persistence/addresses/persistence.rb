# frozen_string_literal: true

module Addresses
  class Persistence
    KEY = 'addresses'
    include Import['redis.pool', 'config', 'redis.lua_cache']
    include Dry::Monads[:result]

    def create(address)
      lua_cache.eval('addresses/create', keys: [KEY], argv: [address])
    end

    def pick_first(with_scores: false)
      result = lua_cache.eval('addresses/pick_first', keys: [KEY])
      format_result(result, with_scores:)
    end

    def destroy(address)
      pool.zrem(KEY, address)
    end

    def exists?(address)
      !!pool.zscore(KEY, address)
    end

    private

    def format_result(values, with_scores: false)
      result, score = values
      return result unless with_scores

      [result, score.to_f]
    end
  end
end
