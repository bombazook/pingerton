# frozen_string_literal: true

RSpec.describe Stats::Index, truncate_click_house: true do
  let(:persistence) { App['stats.persistence'] }
  let(:time) { Time.now }

  describe '#call' do
    context 'with correct address' do
      it 'returns 200' do
        expect(subject.call(address: '1.1.1.1')[0]).to be_eql(200)
      end

      context 'when some data about pings exist' do
        it 'returns some data about pings' do
          expected_body = {
            'avg' => 0.1,
            'count' => 1,
            'max' => 0.1,
            'median' => 0.1,
            'min' => 0.1,
            'stddev' => 0,
            'timeout_percent' => 0
          }
          persistence.create('1.1.1.1', ping: time, pong: time + 0.1)
          parsed_body = JSON.parse(subject.call(address: '1.1.1.1')[2])
          expect(parsed_body).to be == expected_body
        end

        it 'returns zero values if all pongs were out of time limits' do
          expected_body = {
            'avg' => 0.0,
            'count' => 0,
            'max' => 0.0,
            'median' => 0.0,
            'min' => 0.0,
            'stddev' => 0.0,
            'timeout_percent' => 0.0
          }
          persistence.create('1.1.1.1', ping: time, pong: time + 0.1)
          parsed_body = JSON.parse(subject.call(address: '1.1.1.1', from: (time + 1000).to_s)[2])
          expect(parsed_body).to be == expected_body
        end
      end
    end
  end
end
