# frozen_string_literal: true

RSpec.describe Addresses::Destroy do
  let(:persistence) { App['addresses.persistence'] }

  describe '#call' do
    context "when address doesn't exist" do
      it 'returns 404' do
        expect(subject.call(address: '1.1.1.1')[0]).to be_eql(404)
      end
    end

    context 'when address exists' do
      it 'returns 200' do
        persistence.create('1.1.1.1')
        expect(subject.call(address: '1.1.1.1')[0]).to be_eql(200)
      end
    end

    it 'returns 422 if wrong address given' do
      expect(subject.call(address: 'lol')[0]).to be_eql(422)
    end
  end
end
