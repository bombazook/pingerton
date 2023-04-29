# frozen_string_literal: true

RSpec.describe Stats::Index, truncate_click_house: true do
  let(:persistence) { App['stats.persistence'] }
  let(:time) { Time.now }

  describe '#call' do
    context 'when some data about pings exist' do
      it 'returns 200' do
        persistence.create('1.1.1.1', ping: time, pong: time + 0.1)
        expect(subject.call(address: '1.1.1.1')[0]).to be_eql(200)
      end

      it 'returns some data about pings' do
        expected_body = { 'avg' => 0.1, 'count' => 1, 'max' => 0.1, 'median' => 0.1, 'min' => 0.1, 'stddev' => 0,
                          'timeout_percent' => 0 }
        persistence.create('1.1.1.1', ping: time, pong: time + 0.1)
        parsed_body = JSON.parse(subject.call(address: '1.1.1.1')[2])
        expect(parsed_body).to be == expected_body
      end
    end

    context 'when no data of pings for given period exist' do
      it 'returns 418' do
        expect(subject.call(address: '1.1.1.1')[0]).to be_eql(418)
      end
    end
  end
end
