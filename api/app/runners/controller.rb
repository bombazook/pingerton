# frozen_string_literal: true

class Controller < Async::Container::Controller
  def initialize(command, **options)
    @command = command
    @ios = {}

    super(**options)
  end

  def create_container
    @command.container_class.new
  end

  def load_app
    @command.load_app
  end

  def start
    @ios = @command.ios
    ios_string = @ios.map { |k, v| "#{k} socket #{v}" }.join(', ')
    Console.logger.info(self) { "Starting #{name} on #{ios_string}" }

    super
  end

  def name
    'Pingerton'
  end

  def receivers
    @receivers ||= @command.receivers(**@ios)
  end

  def senders
    @senders ||= @command.senders(**@ios)
  end

  def setup(container)
    container.run(name:, restart: true, **@command.container_options) do
      Async do
        receivers.map(&:run)
        senders.map(&:run)
      end
    end
  end

  def stop(*)
    @ios.values.flatten.map(&:close)
    super
  end
end
