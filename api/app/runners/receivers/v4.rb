# frozen_string_literal: true

module Receivers
  class V4
    include Import['pings.destroy']
    MAXIMUM_MESSAGE_SIZE = 4096

    def initialize(socket = nil, **deps)
      super(**deps)
      @socket = socket
    end

    def run
      Async do
        call while true
      end
    end

    def call
      data, host, *other = @socket.recvmsg(MAXIMUM_MESSAGE_SIZE)
      icmp_data = data[20, data.length]
      icmp = parse_ipv4(icmp_data:, host:, other:)
      destroy.call(icmp[:address], sequence: icmp[:packet].sequence)
    end

    def parse_ipv4(icmp_data:, host:, other: nil)
      pong = Protocol::Icmp::V4::Packet.from_bytes(icmp_data)
      Console.logger.debug("Received pong seq #{pong.sequence} from #{host.ip_address} and #{other.inspect}")
      { packet: pong, address: host.ip_address }
    end
  end
end
