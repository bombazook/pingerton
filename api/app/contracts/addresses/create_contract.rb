# frozen_string_literal: true

module Addresses
  class CreateContract < Dry::Validation::Contract
    params do
      required(:address).value(:string)
    end

    rule(:address).validate(:ip_address)
  end
end
