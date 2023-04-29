# frozen_string_literal: true

require_relative './system/boot'

if ENV['RACK_ENV'] == 'development'
  use Rack::Cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: :any
    end
  end
end

run App['api']
