# frozen_string_literal: true

module Addresses
  class DestroyContract < Dry::Validation::Contract
    include Import['addresses.persistence']

    params do
      required(:address).value(:string)
    end

    rule(:address).validate(:ip_address)
    rule(:address) do
      if !schema_error?(:address) && !rule_error?(:address) && !persistence.exists?(value)
        key.failure('record_not_found')
      end
    end
  end
end
