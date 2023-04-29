# frozen_string_literal: true

RSpec.describe Pings::Destroy, truncate_click_house: true do
  let(:create) { App['pings.create'] }

  describe '#call' do
    context 'with sequence' do
      it 'returns error if wrong sequence given (pong)' do
        ping = create.call('1.1.1.1')
        expect(subject.call('1.1.1.1', sequence: ping.success[:data][:sequence] + 1)).to be_failure
      end

      it "creates stat if ping is not expired but correct sequence given (pong)" do
        ping = create.call('1.1.1.1')
        expect(subject.stats).to receive(:create)
        subject.call('1.1.1.1', sequence: ping.success[:data][:sequence])
      end
    end

    it 'creates stat if destroying ping is expired' do
      with_env('PINGERTON_TIMEOUT' => '0') do
        create.call('1.1.1.1')
        expect(subject.stats).to receive(:create)
        subject.call('1.1.1.1')
      end
    end

    it "doesn't create stat if ping is not expired" do
      create.call('1.1.1.1')
      expect(subject.stats).not_to receive(:create)
      subject.call('1.1.1.1')
    end
  end
end
