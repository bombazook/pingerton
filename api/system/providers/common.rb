# frozen_string_literal: true

App.register_provider(:common) do
  prepare do
    require_relative '../import'
    require 'dry-validation'
    require 'dry-monads'
    require 'dry/monads/result'
    require 'dry/matcher/result_matcher'
    require 'rack/cors'
    require 'logger'
    require 'oj'
    require 'anyway_config'
    require 'connection_pool'
    require 'samovar'
    if %w[development test].include?(ENV['RACK_ENV'])
      require 'byebug'
      require 'pry'
    end

    Dry::Validation.load_extensions(:monads)
  end
end
