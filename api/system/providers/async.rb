# frozen_string_literal: true

App.register_provider(:config) do
  prepare do
    require 'async/io'
    require 'async/io/shared_endpoint'
    require 'async/container'
    require 'async/io/trap'
  end
end
