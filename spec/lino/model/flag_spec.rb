# frozen_string_literal: true

require 'spec_helper'

describe Lino::Model::Flag do
  describe '#==' do
    let(:opts) do
      {
        placement: :after_command
      }
    end

    it 'returns true when class and state equal' do
      first = described_class.new('--flag1', opts)
      second = described_class.new('--flag1', opts)

      expect(first == second).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(described_class).new('--flag1', opts)
      second = described_class.new('--flag1', opts)

      expect(first == second).to(be(false))
    end

    it 'returns false when flag different' do
      first = described_class.new('--flag1', opts)
      second = described_class.new('--flag2', opts)

      expect(first == second).to(be(false))
    end

    it 'returns false when option placement different' do
      first = described_class.new(
        '--flag1',
        opts.merge(placement: :after_command)
      )
      second = described_class.new(
        '--flag1',
        opts.merge(placement: :after_subcommands)
      )

      expect(first == second).to(be(false))
    end
  end

  describe '#eql?' do
    let(:opts) do
      {
        placement: :after_command
      }
    end

    it 'returns true when class and state equal' do
      first = described_class.new('--flag1', opts)
      second = described_class.new('--flag1', opts)

      expect(first.eql?(second)).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(described_class).new('--flag1', opts)
      second = described_class.new('--flag1', opts)

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when flag different' do
      first = described_class.new('--flag1', opts)
      second = described_class.new('--flag2', opts)

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when flag placement different' do
      first = described_class.new(
        '--flag1',
        opts.merge(placement: :after_command)
      )
      second = described_class.new(
        '--flag1',
        opts.merge(placement: :after_subcommands)
      )

      expect(first.eql?(second)).to(be(false))
    end
  end

  describe '#hash' do
    let(:opts) do
      {
        placement: :after_command
      }
    end

    it 'has same hash when class and state equal' do
      first = described_class.new('--flag1', opts)
      second = described_class.new('--flag1', opts)

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash when class different' do
      first = Class.new(described_class).new('--flag1', opts)
      second = described_class.new('--flag1', opts)

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when flag different' do
      first = described_class.new('--flag1', opts)
      second = described_class.new('--flag2', opts)

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when flag placement different' do
      first = described_class.new(
        '--flag1',
        opts.merge(placement: :after_command)
      )
      second = described_class.new(
        '--flag1',
        opts.merge(placement: :after_subcommands)
      )

      expect(first.hash).not_to(eq(second.hash))
    end
  end

  describe '#string' do
    it 'returns flag if string' do
      expect(described_class.new('--flag').string)
        .to(eq('--flag'))
    end

    it 'converts non-string flag to string before returning' do
      flag_class = Class.new do
        def to_s
          '-h'
        end
      end
      flag = flag_class.new

      expect(described_class.new(flag).string)
        .to(eq('-h'))
    end
  end

  describe '#array' do
    it 'returns array with flag as only item' do
      expect(described_class.new('--flag').array)
        .to(eq(%w[--flag]))
    end

    it 'converts non-string flag to string before adding to array' do
      flag_class = Class.new do
        def to_s
          '-h'
        end
      end
      flag = flag_class.new

      expect(described_class.new(flag).array)
        .to(eq(%w[-h]))
    end
  end
end
