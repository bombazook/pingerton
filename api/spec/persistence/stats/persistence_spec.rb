# frozen_string_literal: true

RSpec.describe Stats::Persistence, truncate_click_house: true do
  let(:pool) { App['clickhouse.pool'] }
  let(:time) { Time.now }

  shared_examples 'able to use stats' do
    describe '#create' do
      it 'adds record to corresponding table' do
        subject.create(ip, ping: time, pong: time + 0.1)
        ping = pool.select_one("SELECT * FROM #{table} ORDER BY ping DESC LIMIT 1")
        expected_ping = {
          ip: IPAddr.new(ip),
          ping: time.round(3),
          pong: (time + 0.1).round(3),
          duration: 0.1,
          timeout: false
        }
        expect(ping[:ping] - expected_ping[:ping]).to be <= 0.001
        expect(ping[:pong] - expected_ping[:pong]).to be <= 0.001
        expect(ping[:duration]).to be_eql(expected_ping[:duration])
      end
    end

    describe '#get' do
      it 'returns correct ipv4 info if ipv4 pings exist' do
        subject.create(ip, ping: time, pong: time + 0.1)
        subject.create(ip, ping: time + 10, pong: time + 10 + 0.6)
        subject.create(ip, ping: time + 20, pong: time + 20 + 0.8)
        subject.create(ip, ping: time + 30, pong: time + 200)
        values = [0.1, 0.6, 0.8]
        avg = values.inject(&:+) / values.size
        expected_deviation = Math.sqrt(values.inject(0) { |m, v| m + ((v - avg)**2) } / (values.size - 1))
        expected_stats = {
          count: 4,
          avg:,
          max: 0.8,
          min: 0.1,
          stddev: expected_deviation,
          median: 0.6,
          timeout_percent: 0.25
        }
        expect(described_class.new.get(ip)).to be_eql(expected_stats)
      end

      it 'returns 0 values if no info about ipv4 pings' do
        expected_stats = {
          count: 0,
          avg: 0.0,
          max: 0.0,
          min: 0.0,
          stddev: 0.0,
          median: 0.0,
          timeout_percent: 0.0
        }
        expect(described_class.new.get(ip)).to be_eql(expected_stats)
      end
    end
  end

  context 'with ipv4' do
    let(:ip) { '1.1.1.1' }
    let(:table) { 'ipv4pings' }

    it_behaves_like 'able to use stats'
  end

  context 'with ipv6' do
    let(:ip) { '2001:0db8:0000:0000:0000:ff00:0042:8329' }
    let(:table) { 'ipv6pings' }

    it_behaves_like 'able to use stats'
  end
end
