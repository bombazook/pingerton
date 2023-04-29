# frozen_string_literal: true

module Pings
  module ServiceMethods
    include Dry::Monads[:result]

    def parse_result(result)
      case result[:status]
      when 'retry_later'
        Failure(Errors::RetryLaterError.new(px: result[:data]))
      when 'expired'
        Success(data: result[:data], expired_data: build_expired_data(result))
      when 'error'
        Failure(Errors::WrongAttributesError.new(result[:data]))
      else
        Success(data: result[:data])
      end
    end

    def create_stat(address, data, **opts)
      options = { ping: Time.at(data[:time]), pong: data[:expired_at] || Time.now, timeout: false }.merge(opts)
      stats.create(address, **options)
    end

    private

    def build_expired_data(result)
      expired_data = result[:expired_data]
      expired_data[:expired_at] = expired_data[:time] + (config.timeout / 1000)
      expired_data
    end
  end
end
