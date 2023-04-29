# frozen_string_literal: true

RSpec.describe Addresses::CreateContract do
  describe '#call' do
    it 'fails if wrong address given' do
      expect(subject.call(address: 'lalala')).to be_failure
    end

    it 'fails if no address given' do
      expect(subject.call({})).to be_failure
    end

    it 'success if correct ipv4 given' do
      expect(subject.call(address: '1.1.1.1')).to be_success
    end

    it 'success if correct ipv6 given', skip: 'ipv6 pong not implemented' do
      expect(subject.call(address: '2606:4700:4700:0:0:0:0:64')).to be_success
    end
  end
end
