# frozen_string_literal: true

RSpec.describe Senders::V4 do
  subject { described_class.new(ios[:v4_io]) }

  include_context Async::RSpec::Reactor

  let(:ios) { Command.new.ios }
  let(:addresses) { Addresses::Persistence.new }

  after { ios.values.map(&:close) }

  it 'sends ping with corresponding sequence number' do
    addresses.create('127.0.0.1')
    reactor.async do
      subject.call
    end

    data, = ios[:v4_io].recvmsg
    icmp_data = data[20, data.length]
    icmp = Protocol::Icmp::V4::Packet.from_bytes(icmp_data)
    _, sequence = addresses.pick_first(with_scores: true)
    expect(icmp.sequence).to be_eql(sequence.to_i - 1)
  end
end
