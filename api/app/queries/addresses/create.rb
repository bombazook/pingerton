# frozen_string_literal: true

module Addresses
  class Create < BaseQuery
    include Import['addresses.persistence', 'addresses.create_contract']
    include Dry::Monads::Do.for(:run)
    include Dry::Matcher.for(:run, with: Dry::Matcher::ResultMatcher)

    private

    def run(params)
      contract_result = yield create_contract.call(params)
      Success(persistence.create(contract_result.to_h[:address]))
    end
  end
end
