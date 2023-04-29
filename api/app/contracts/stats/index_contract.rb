# frozen_string_literal: true

module Stats
  class IndexContract < Dry::Validation::Contract
    params do
      required(:address).value(:string)
      optional(:from).value(:date_time)
      optional(:to).value(:date_time)
    end

    rule(:address).validate(:ip_address)
    rule(:to) do
      key.failure("should be greater than 'from' value") if value && values[:from] && value < values[:from]
    end
  end
end
