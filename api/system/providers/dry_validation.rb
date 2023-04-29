# frozen_string_literal: true

App.register_provider(:dry_validation) do
  prepare do
    target.prepare :common
    require 'dry-validation'
    require 'dry-monads'

    Dry::Validation.load_extensions(:monads)

    Dry::Validation.register_macro(:ip_address) do
      if value && value !~ Resolv::IPv4::Regex && value !~ Resolv::IPv6::Regex
        key.failure('must be valid ipv4 or ipv6 address')
      end
    end
  end
end
