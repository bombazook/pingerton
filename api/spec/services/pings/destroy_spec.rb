# frozen_string_literal: true

RSpec.describe Pings::Destroy, truncate_click_house: true do
  let(:ping) { App['pings.create'].call('1.1.1.1') }
  let(:stats_persistence) { instance_spy(Stats::Persistence) }

  describe '#call' do
    context 'with sequence' do
      it 'returns error if wrong sequence given (pong)' do
        expect(subject.call('1.1.1.1', sequence: ping.success[:data][:sequence] + 1)).to be_failure
      end

      it 'creates stat if ping is not expired but correct sequence given (pong)' do
        allow(subject).to receive(:stats).and_return(stats_persistence)
        subject.call('1.1.1.1', sequence: ping.success[:data][:sequence])
        expect(stats_persistence).to have_received(:create)
      end
    end

    it 'creates stat if destroying ping is expired' do
      with_env('PINGERTON_TIMEOUT' => '0') do
        allow(subject).to receive(:stats).and_return(stats_persistence)
        ping
        subject.call('1.1.1.1')
        expect(stats_persistence).to have_received(:create)
      end
    end

    it "doesn't create stat if ping is not expired" do
      allow(subject).to receive(:stats).and_return(stats_persistence)
      ping
      subject.call('1.1.1.1')
      expect(stats_persistence).not_to have_received(:create)
    end
  end
end
