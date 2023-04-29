# frozen_string_literal: true

class Command < Samovar::Command
  self.description = 'Run a pingerton service'

  options do
    option '--clickhouse-url <url>', 'Clickhouse url', key: :clickhouse_url
    option '--clickhouse-db <url>', 'Clickhouse database name', key: :clickhouse_db
    option '--redis-url <url>', 'Redis url', key: :redis_url
    option '-t/--timeout <duration>', 'Specify ping timeout', type: Integer
    option '-p/--period <period>', 'Specify ping period (new iteration)', type: Integer
    option '-c/--config <path>', 'configuration file to load.'
    option '--forked | --threaded | --hybrid', 'Select a specific parallelism model.', key: :container, default: :forked
    option '-n/--count <count>', 'Number of instances to start.', default: Async::Container.processor_count,
                                                                  type: Integer
    option '--forks <count>', 'Number of forks (hybrid only).', type: Integer
    option '--threads <count>', 'Number of threads (hybrid only).', type: Integer
    option '-d/--debug', 'Debug console logging'
  end

  def container_class
    case @options[:container]
    when :threaded
      Async::Container::Threaded
    when :forked
      Async::Container::Forked
    when :hybrid
      Async::Container::Hybrid
    end
  end

  def container_options
    @options.slice(:count, :forks, :threads)
  end

  def config_options
    @options.slice(:clickhouse_url, :clickhouse_db, :timeout, :period)
  end

  def controller
    Controller.new(self)
  end

  def ios
    socket = Socket.new(Socket::PF_INET, Socket::SOCK_RAW, Socket::IPPROTO_ICMP)
    socket.setsockopt Socket::SOL_SOCKET, Socket::SO_REUSEPORT, true
    { v4: Async::IO::Socket.new(socket) }
  end

  def receivers(v4: nil)
    [Receivers::V4.new(v4)]
  end

  def senders(v4: nil)
    [Senders::V4.new(v4)]
  end

  def call
    Console.logger.debug! if options[:debug]

    require_relative '../../system/load'
    App.register('config.cli_options', config_options)
    App.finalize!

    Console.logger.info(self) do |buffer|
      buffer.puts "Pingerton v#{::Version} taking flight! Using #{container_class} #{container_options}."
      buffer.puts "- To terminate: Ctrl-C or kill #{Process.pid}"
      buffer.puts "- To reload configuration: kill -HUP #{Process.pid}"
    end

    GC.compact if GC.respond_to?(:compact)

    controller.run
  end
end
