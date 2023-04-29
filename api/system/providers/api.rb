# frozen_string_literal: true

App.register_provider(:api) do
  prepare do
    require 'hanami/api'
  end
end
