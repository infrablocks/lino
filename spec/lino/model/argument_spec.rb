# frozen_string_literal: true

require 'spec_helper'

describe Lino::Model::Argument do
  describe '#==' do
    it 'returns true when class and state equal' do
      first = described_class.new('arg')
      second = described_class.new('arg')

      expect(first == second).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(described_class).new('arg')
      second = described_class.new('arg')

      expect(first == second).to(be(false))
    end

    it 'returns false when argument different' do
      first = described_class.new('arg1')
      second = described_class.new('arg2')

      expect(first == second).to(be(false))
    end
  end

  describe '#eql?' do
    it 'returns true when class and state equal' do
      first = described_class.new('arg')
      second = described_class.new('arg')

      expect(first.eql?(second)).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(described_class).new('arg')
      second = described_class.new('arg')

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when argument different' do
      first = described_class.new('arg1')
      second = described_class.new('arg2')

      expect(first.eql?(second)).to(be(false))
    end
  end

  describe '#hash' do
    it 'has same hash when class and state equal' do
      first = described_class.new('arg')
      second = described_class.new('arg')

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash when class different' do
      first = Class.new(described_class).new('arg')
      second = described_class.new('arg')

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when flag different' do
      first = described_class.new('arg1')
      second = described_class.new('arg2')

      expect(first.hash).not_to(eq(second.hash))
    end
  end

  describe '#string' do
    it 'returns flag' do
      expect(described_class.new('arg').string)
        .to(eq('arg'))
    end
  end

  describe '#array' do
    it 'returns array with flag as only item' do
      expect(described_class.new('arg').array)
        .to(eq(%w[arg]))
    end
  end
end
