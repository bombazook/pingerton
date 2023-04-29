# frozen_string_literal: true

RSpec.describe Pings::Create, truncate_click_house: true do
  let(:stats_persistence) { instance_spy(Stats::Persistence) }

  describe '#call' do
    it "doesn't create stat if no expired ping exists" do
      allow(subject).to receive(:stats).and_return(stats_persistence)
      subject.call('1.1.1.1')
      expect(stats_persistence).not_to have_received(:create)
    end

    it 'creates stat if expired ping exists' do
      with_env('PINGERTON_TIMEOUT' => '0') do
        subject.call('1.1.1.1')
        allow(subject).to receive(:stats).and_return(stats_persistence)
        subject.call('1.1.1.1')
        expect(stats_persistence).to have_received(:create)
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
