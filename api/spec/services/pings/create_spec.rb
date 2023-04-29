# frozen_string_literal: true

RSpec.describe Pings::Create, truncate_click_house: true do
  describe '#call' do
    it "doesn't create stat if no expired ping exists" do
      expect(subject.stats).not_to receive(:create)
      subject.call('1.1.1.1')
    end

    it 'creates stat if expired ping exists' do
      with_env('PINGERTON_TIMEOUT' => '0') do
        subject.call('1.1.1.1')
        expect(subject.stats).to receive(:create)
        subject.call('1.1.1.1')
      end
    end

    it 'returns failure with expiration time if not expired ping exists' do
      subject.call('1.1.1.1')
      expect(subject.call('1.1.1.1').failure.meta).to include(:px)
    end

    it 'returns ping data if successes' do
      expect(subject.call('1.1.1.1').success).to include(:data)
    end
  end
end
