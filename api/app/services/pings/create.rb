# frozen_string_literal: true

module Pings
  class Create
    include Pings::ServiceMethods
    include Import[pings: 'pings.persistence', stats: 'stats.persistence', config: 'config']
    include Dry::Monads::Do.for(:call)

    def call(address, **opts)
      result = yield parse_result(pings.create(address, **opts))
      expired_data = result[:expired_data]
      create_stat(address, expired_data, timeout: true) if expired_data
      Success(result)
    end
  end
end
