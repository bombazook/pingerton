# frozen_string_literal: true

RSpec.describe Addresses::Persistence do
  let(:pool) { App['redis.pool'] }

  describe '#create' do
    it 'does nothing if address exists' do
      pool.zadd(described_class::KEY, 4, '8.8.8.8')
      subject.create('1.1.1.1')
      pool.zadd(described_class::KEY, 3, '8.8.8.8')
      subject.create('1.1.1.1')
      values = pool.zrange(described_class::KEY, 0, -1, with_scores: true)
      expect(values).to be_eql([['8.8.8.8', 3.0], ['1.1.1.1', 4.0]])
    end

    it 'adds address to monitoring set' do
      subject.create('1.1.1.1')
      expect(pool.zrange(described_class::KEY, 0, -1)).to be_eql(['1.1.1.1'])
    end

    it 'sets address score to minimum existing score' do
      pool.zadd(described_class::KEY, 4, '8.8.8.8')
      subject.create('1.1.1.1')
      values = pool.zrange(described_class::KEY, 0, -1, with_scores: true)
      expect(values).to be_eql([['1.1.1.1', 4.0], ['8.8.8.8', 4.0]])
    end

    it 'sets address score to 1 if no address exists' do
      subject.create('1.1.1.1')
      values = pool.zrange(described_class::KEY, 0, -1, with_scores: true)
      expect(values).to be_eql([['1.1.1.1', 1.0]])
    end
  end

  describe '#destroy' do
    it 'removes address from monitoring set' do
      subject.create('1.1.1.1')
      subject.destroy('1.1.1.1')
      expect(pool.zrange(described_class::KEY, 0, -1)).to be_eql([])
    end
  end

  describe '#pick_first' do
    it 'returns address with least score' do
      pool.zadd(described_class::KEY, 3, '8.8.8.8')
      pool.zadd(described_class::KEY, 2, '1.1.1.1')
      expect(subject.pick_first).to be_eql('1.1.1.1')
    end

    it 'returns address with score if option given' do
      subject.create('1.1.1.1')
      expect(subject.pick_first(with_scores: true)).to be_eql(['1.1.1.1', 1.0])
    end

    it 'increments returned element score' do
      pool.zadd(described_class::KEY, 3, '8.8.8.8')
      pool.zadd(described_class::KEY, 2, '1.1.1.1')
      subject.pick_first
      values = pool.zrange(described_class::KEY, 0, -1, with_scores: true)
      expect(values).to be_eql([['1.1.1.1', 3.0], ['8.8.8.8', 3.0]])
    end
  end
end
