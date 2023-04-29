# frozen_string_literal: true

module Addresses
  class PickFirstWithLock
    LOCK_KEY = 'addresses.lock'
    include Import['config', 'redis.lua_cache', 'addresses.persistence']
    include Dry::Monads[:result]

    def call(period: config.period, lock_key: LOCK_KEY)
      result = lua_cache.eval('addresses/pick_first_with_lock', keys: [persistence.class::KEY, lock_key],
                                                                argv: [period])
      address, score = result
      return Success([address, score.to_f]) if result.is_a?(Array)

      Failure(Errors::RetryLaterError.new(retry_after: result || period))
    end
  end
end
