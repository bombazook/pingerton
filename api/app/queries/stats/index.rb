# frozen_string_literal: true

module Stats
  class Index < BaseQuery
    include Import['stats.persistence', 'stats.index_contract']
    include Dry::Monads::Do.for(:run)
    include Dry::Matcher.for(:run, with: Dry::Matcher::ResultMatcher)

    private

    def run(params)
      contract_result = yield index_contract.call(params)
      result = contract_result.to_h
      data = persistence.get(result.delete(:address))
      return Failure(Errors::NoDataError.new) if (data[:count]).zero?

      Success(data, **result)
    end
  end
end
