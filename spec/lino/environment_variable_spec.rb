# frozen_string_literal: true

require 'spec_helper'

describe Lino::EnvironmentVariable do
  describe '#==' do
    let(:opts) do
      {
        quoting: nil
      }
    end

    it 'returns true when class and state equal' do
      first = described_class.new('ENV_VAR', 'val', opts)
      second = described_class.new('ENV_VAR', 'val', opts)

      expect(first == second).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(described_class).new('ENV_VAR', 'val', opts)
      second = described_class.new('ENV_VAR', 'val', opts)

      expect(first == second).to(be(false))
    end

    it 'returns false when name different' do
      first = described_class.new('ENV_VAR1', 'val', opts)
      second = described_class.new('ENV_VAR2', 'val', opts)

      expect(first == second).to(be(false))
    end

    it 'returns false when value different' do
      first = described_class.new('ENV_VAR', 'val1', opts)
      second = described_class.new('ENV_VAR', 'val2', opts)

      expect(first == second).to(be(false))
    end

    it 'returns false when quoting different' do
      first = described_class.new(
        'ENV_VAR', 'val', opts.merge(quoting: '"')
      )
      second = described_class.new(
        'ENV_VAR', 'val', opts.merge(quoting: "'")
      )

      expect(first == second).to(be(false))
    end
  end

  describe '#eql?' do
    let(:opts) do
      {
        quoting: nil
      }
    end

    it 'returns true when class and state equal' do
      first = described_class.new('ENV_VAR', 'val', opts)
      second = described_class.new('ENV_VAR', 'val', opts)

      expect(first.eql?(second)).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(described_class).new('ENV_VAR', 'val', opts)
      second = described_class.new('ENV_VAR', 'val', opts)

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when name different' do
      first = described_class.new('ENV_VAR1', 'val', opts)
      second = described_class.new('ENV_VAR2', 'val', opts)

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when value different' do
      first = described_class.new('ENV_VAR', 'val1', opts)
      second = described_class.new('ENV_VAR', 'val2', opts)

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when option quoting different' do
      first = described_class.new(
        'ENV_VAR', 'val',
        opts.merge(quoting: '"')
      )
      second = described_class.new(
        'ENV_VAR', 'val',
        opts.merge(quoting: "'")
      )

      expect(first.eql?(second)).to(be(false))
    end
  end

  describe '#hash' do
    let(:opts) do
      {
        quoting: nil
      }
    end

    it 'has same hash when class and state equal' do
      first = described_class.new('ENV_VAR', 'val', opts)
      second = described_class.new('ENV_VAR', 'val', opts)

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash when class different' do
      first = Class.new(described_class).new('ENV_VAR', 'val', opts)
      second = described_class.new('ENV_VAR', 'val', opts)

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when name different' do
      first = described_class.new('ENV_VAR1', 'val', opts)
      second = described_class.new('ENV_VAR2', 'val', opts)

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when value different' do
      first = described_class.new('ENV_VAR', 'val1', opts)
      second = described_class.new('ENV_VAR', 'val2', opts)

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when quoting different' do
      first = described_class.new(
        'ENV_VAR', 'val',
        opts.merge(quoting: '"')
      )
      second = described_class.new(
        'ENV_VAR', 'val',
        opts.merge(quoting: "'")
      )

      expect(first.hash).not_to(eq(second.hash))
    end
  end

  describe '#string' do
    it 'uses double quote quoting by default' do
      expect(described_class.new('ENV_VAR', 'val').string)
        .to(eq('ENV_VAR="val"'))
    end

    it 'uses specified quoting when provided' do
      expect(described_class
               .new('ENV_VAR', 'val', quoting: "'")
               .string)
        .to(eq("ENV_VAR='val'"))
    end
  end

  describe '#array' do
    it 'returns name and value as items in an array' do
      expect(described_class.new('ENV_VAR', 'val').array)
        .to(eq(%w[ENV_VAR val]))
    end

    it 'ignores quoting' do
      expect(described_class
               .new('ENV_VAR', 'val', quoting: "'")
               .array)
        .to(eq(%w[ENV_VAR val]))
    end
  end
end
