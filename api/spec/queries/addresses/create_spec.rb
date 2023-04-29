# frozen_string_literal: true

RSpec.describe Addresses::Create do
  describe '#call' do
    it 'returns 200 if correct address given' do
      expect(subject.call(address: '1.1.1.1')[0]).to be_eql(200)
    end

    it 'returns 422 if wrong address given' do
      expect(subject.call(address: 'lol')[0]).to be_eql(422)
    end
  end
end
