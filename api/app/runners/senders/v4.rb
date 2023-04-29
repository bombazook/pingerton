# frozen_string_literal: true

module Senders
  class V4
    include Import['addresses.pick_first_with_lock', 'pings.create']
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:send_ping)
    include Dry::Matcher.for(:send_ping, with: Dry::Matcher::ResultMatcher)

    def initialize(socket = nil, **deps)
      super(**deps)
      @socket = socket
    end

    def run
      Async do |task|
        call(task:) while true
      end
    end

    def call(task: nil)
      send_ping do |m|
        m.success do |result|
          send(ip: result[:ip], sequence: result[:sequence])
        end

        m.failure do |sleep|
          sleep_for(sleep, task:)
        end
      end
    end

    def send_ping
      ip, sequence = yield pick_first_with_lock.call
      yield create.call(ip, sequence:)
      Console.logger.debug("Sending #{ip} with seq #{sequence}")
      Success({ ip:, sequence: })
    end

    def send(ip:, sequence:)
      packet = Protocol::Icmp::V4::Packet.new(sequence:).to_bytes
      address = Socket.pack_sockaddr_in(0, ip)
      @socket.send packet, 0, address
    end

    def sleep_for(result, task:)
      seconds = result.meta[:retry_after].to_f / 1000
      Console.logger.debug("Sleeping for (#{seconds}) seconds")
      task.sleep(seconds)
    end
  end
end
