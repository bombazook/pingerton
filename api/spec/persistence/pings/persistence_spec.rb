# frozen_string_literal: true

RSpec.describe Pings::Persistence do
  let(:pool) { App['redis.pool'] }

  describe '#create' do
    let(:time) { Time.now }

    context "when previous ping doesn't exist" do
      it 'creates expiration key with sequence number on ping creation' do
        subject.create('1.1.1.1', sequence: 5, time:)
        key = subject.send(:timeout_key, '1.1.1.1')
        expect(pool.get(key)).to be_eql('5')
      end

      it 'adds address to ping_sequence set with corresponding sequence' do
        subject.create('1.1.1.1', sequence: 5, time:)
        ping_info = JSON.parse(pool.hget(described_class::KEY, '1.1.1.1'))
        expected_object = { 'sequence' => 5, 'time' => time.to_f }
        expect(ping_info).to be_eql(expected_object)
      end

      it 'returns "done" on ping creation' do
        ping_info = subject.create('1.1.1.1', sequence: 5, time:)
        expected_object = { sequence: 5, time: time.to_f }
        expect(ping_info[:status]).to be_eql('done')
        expect(ping_info[:data]).to be_eql(expected_object)
      end
    end

    context 'when expired ping exists' do
      it 'returns expired ping info' do
        with_env('PINGERTON_TIMEOUT' => '0') do
          subject.create('1.1.1.1', sequence: 4)
          ping_info = subject.create('1.1.1.1', sequence: 5)
          expect(ping_info[:status]).to be_eql('expired')
          expect(ping_info[:expired_data][:sequence]).to be_eql(4)
        end
      end
    end

    context 'when current ping still in progress' do
      it 'returns retry_later with remaining ms' do
        subject.create('1.1.1.1', sequence: 4)
        ping_info = subject.create('1.1.1.1', sequence: 5)
        expect(ping_info[:status]).to be_eql('retry_later')
        expect(ping_info[:data]).to be_a(Integer)
      end
    end
  end

  describe '#destroy' do
    it 'returns error if wrong sequence given' do
      subject.create('1.1.1.1', sequence: 4)
      result = subject.destroy('1.1.1.1', sequence: 5)
      expect(result[:status]).to be_eql('error')
    end

    it 'deletes ping for given ip' do
      subject.create('1.1.1.1', sequence: 4)
      subject.destroy('1.1.1.1')
      expect(pool.hget(described_class::KEY, '1.1.1.1')).to be_nil
    end

    it 'returns ping info with duration if sequence is correct and ping is not expired' do
      subject.create('1.1.1.1', sequence: 4)
      result = subject.destroy('1.1.1.1', sequence: 4)
      expect(result[:data][:sequence]).to be_eql(4)
    end

    context 'when expired ping exists' do
      it 'returns expired ping info' do
        with_env('PINGERTON_TIMEOUT' => '0') do
          subject.create('1.1.1.1', sequence: 4)
          ping_info = subject.destroy('1.1.1.1')
          expect(ping_info[:status]).to be_eql('expired')
          expect(ping_info[:expired_data][:sequence]).to be_eql(4)
        end
      end
    end
  end
end
