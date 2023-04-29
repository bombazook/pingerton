# frozen_string_literal: true

RSpec.describe Receivers::V4 do
  subject { described_class.new(ios[:v4_io]) }

  include_context Async::RSpec::Reactor

  let(:ios) { Command.new.ios }
  let(:destroy_service) { instance_spy(Pings::Destroy) }

  after { ios.values.map(&:close) }

  it 'calls pings destroy service with received pong params' do
    allow(subject).to receive(:destroy).and_return(destroy_service)
    packet = Protocol::Icmp::V4::Packet.new(
      sequence: 3, type: Protocol::Icmp::V4::Packet::ICMP_ECHO_REPLY
    ).to_bytes
    ios[:v4_io].send(packet, 0, Socket.pack_sockaddr_in(0, '127.0.0.1'))
    reactor.async do
      subject.call
    end
    expect(destroy_service).to have_received(:call).with('127.0.0.1', sequence: 3)
  end
end
