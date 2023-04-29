# frozen_string_literal: true

module Pings
  class Destroy
    include Pings::ServiceMethods
    include Import[pings: 'pings.persistence', stats: 'stats.persistence', config: 'config']
    include Dry::Monads::Do.for(:call)

    def call(address, **opts)
      result = yield parse_result(pings.destroy(address, **opts))
      data = result[:data]
      create_stat(address, data) if data&.key?(:sequence) && opts[:sequence] == data[:sequence]
      expired_data = result[:expired_data]
      create_stat(address, expired_data, timeout: true) if expired_data
      Success()
    end
  end
end
