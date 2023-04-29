# frozen_string_literal: true

RSpec.describe Addresses::DestroyContract do
  let(:persistence) { App['addresses.persistence'] }

  describe '#call' do
    it 'fails if wrong address given' do
      expect(subject.call(address: 'lalala')).to be_failure
    end

    it 'fails if no address given' do
      expect(subject.call({})).to be_failure
    end

    it 'fails if non-existing correct ipv4 given' do
      expect(subject.call(address: '1.1.1.1')).to be_failure
    end

    it 'fails if non-existing correct ipv6 given' do
      expect(subject.call(address: '2606:4700:4700:0:0:0:0:64')).to be_failure
    end

    it 'success if correct existing ipv4 given' do
      persistence.create('1.1.1.1')
      expect(subject.call(address: '1.1.1.1')).to be_success
    end

    it 'success if correct existing ipv6 given' do
      persistence.create('2606:4700:4700:0:0:0:0:64')
      expect(subject.call(address: '2606:4700:4700:0:0:0:0:64')).to be_success
    end
  end
end
