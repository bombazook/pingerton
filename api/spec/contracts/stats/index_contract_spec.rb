# frozen_string_literal: true

RSpec.describe Stats::IndexContract do
  describe '#call' do
    it 'fails if wrong address given' do
      expect(subject.call(address: 'lalala')).to be_failure
    end

    it 'fails if no address given' do
      expect(subject.call({})).to be_failure
    end

    it 'fails if wrong timestamp in from given' do
      expect(subject.call(address: '1.1.1.1', from: 'lol')).to be_failure
    end

    it 'fails if wrong timestamp in to given' do
      expect(subject.call(address: '1.1.1.1', to: 'lol')).to be_failure
    end

    it 'fails if to < from' do
      expect(subject.call(address: '1.1.1.1',
                          from: '2022-01-01 22:22:22.312 +06:00',
                          to: '2020-01-01 22:22:22.312 +06:00')).to be_failure
    end

    it 'success if only to given' do
      expect(subject.call(address: '1.1.1.1',
                          to: '2020-01-01 22:22:22.312 +06:00')).to be_success
    end

    it 'success if only from given' do
      expect(subject.call(address: '1.1.1.1',
                          from: '2020-01-01 22:22:22.312 +06:00')).to be_success
    end

    it 'success if correct ipv4 given' do
      expect(subject.call(address: '1.1.1.1')).to be_success
    end

    it 'success if correct ipv6 given' do
      expect(subject.call(address: '2606:4700:4700:0:0:0:0:64')).to be_success
    end
  end
end
