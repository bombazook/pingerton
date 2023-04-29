# frozen_string_literal: true

module Addresses
  class Destroy < BaseQuery
    include Import['addresses.persistence', 'addresses.destroy_contract']
    include Import[pings_destroy: 'pings.destroy']
    include Dry::Monads::Do.for(:run)
    include Dry::Matcher.for(:run, with: Dry::Matcher::ResultMatcher)

    private

    def run(params)
      contract_result = yield destroy_contract.call(params)
      address = contract_result[:address]
      persistence.destroy(address)
      pings_destroy.call(address) # destroying current pings
      Success(address)
    end
  end
end
