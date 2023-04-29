# frozen_string_literal: true

RSpec.describe Addresses::PickFirstWithLock do
  let(:persistence) { App['addresses.persistence'] }
  let(:pool) { App['redis.pool'] }

  describe '#call' do
    it 'creates lock with value of first taken score' do
      pool.zadd(persistence.class::KEY, 3, '8.8.8.8')
      subject.call
      expect(pool.get(described_class::LOCK_KEY).to_i).to be_eql(3)
    end

    it 'returns Failure monad with RetryLater error and remaining time if score of taken value is > of lock' do
      pool.zadd(persistence.class::KEY, 3, '8.8.8.8')
      subject.call
      expect(subject.call.failure.meta[:retry_after]).not_to be_nil
    end
  end
end
