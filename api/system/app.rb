# frozen_string_literal: true

require 'dry/system'

class App < Dry::System::Container
  use :env, inferrer: -> { ENV.fetch('RACK_ENV', :development).to_sym }
  use :zeitwerk, debug: (ENV['RACK_ENV'] == 'development' && ENV.fetch('ZEITWERK_DEBUG', nil))

  configure do |config|
    config.component_dirs.add 'config'
    config.component_dirs.add 'lib'
    config.component_dirs.add 'app/queries'
    config.component_dirs.add 'app/contracts'
    config.component_dirs.add 'app/persistence'
    config.component_dirs.add 'app/services'
    config.component_dirs.add 'app/runners'
  end
end
