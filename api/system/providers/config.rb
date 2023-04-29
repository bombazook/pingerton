# frozen_string_literal: true

App.register_provider(:config) do
  prepare do
    require 'anyway_config'
    if App['config.cli_options']
      Anyway.loaders.insert_before :env, Class.new(Anyway::Loaders::Base) do
        define_method :call do
          App['config.cli_options']
        end
      end
    end
  end
end
