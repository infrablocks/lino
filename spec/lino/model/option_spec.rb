# frozen_string_literal: true

require 'spec_helper'

describe Lino::Model::Option do
  describe '#==' do
    let(:opts) do
      {
        separator: ' ',
        quoting: nil,
        placement: :after_command
      }
    end

    it 'returns true when class and state equal' do
      first = described_class.new('--opt1', 'val1', opts)
      second = described_class.new('--opt1', 'val1', opts)

      expect(first == second).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(described_class).new('--opt1', 'val1', opts)
      second = described_class.new('--opt1', 'val1', opts)

      expect(first == second).to(be(false))
    end

    it 'returns false when option different' do
      first = described_class.new('--opt1', 'val1', opts)
      second = described_class.new('--opt2', 'val1', opts)

      expect(first == second).to(be(false))
    end

    it 'returns false when value different' do
      first = described_class.new('--opt1', 'val1', opts)
      second = described_class.new('--opt1', 'val2', opts)

      expect(first == second).to(be(false))
    end

    it 'returns false when option separator different' do
      first = described_class.new(
        '--opt1', 'val1',
        opts.merge(separator: ' ')
      )
      second = described_class.new(
        '--opt1', 'val1',
        opts.merge(separator: '=')
      )

      expect(first == second).to(be(false))
    end

    it 'returns false when option quoting different' do
      first = described_class.new(
        '--opt1', 'val1',
        opts.merge(quoting: '"')
      )
      second = described_class.new(
        '--opt1', 'val1',
        opts.merge(quoting: "'")
      )

      expect(first == second).to(be(false))
    end

    it 'returns false when option placement different' do
      first = described_class.new(
        '--opt1', 'val1',
        opts.merge(placement: :after_command)
      )
      second = described_class.new(
        '--opt1', 'val1',
        opts.merge(placement: :after_subcommands)
      )

      expect(first == second).to(be(false))
    end
  end

  describe '#eql?' do
    let(:opts) do
      {
        separator: ' ',
        quoting: nil,
        placement: :after_command
      }
    end

    it 'returns true when class and state equal' do
      first = described_class.new('--opt1', 'val1', opts)
      second = described_class.new('--opt1', 'val1', opts)

      expect(first.eql?(second)).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(described_class).new('--opt1', 'val1', opts)
      second = described_class.new('--opt1', 'val1', opts)

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when option different' do
      first = described_class.new('--opt1', 'val1', opts)
      second = described_class.new('--opt2', 'val1', opts)

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when value different' do
      first = described_class.new('--opt1', 'val1', opts)
      second = described_class.new('--opt1', 'val2', opts)

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when option separator different' do
      first = described_class.new(
        '--opt1', 'val1',
        opts.merge(separator: ' ')
      )
      second = described_class.new(
        '--opt1', 'val1',
        opts.merge(separator: '=')
      )

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when option quoting different' do
      first = described_class.new(
        '--opt1', 'val1',
        opts.merge(quoting: '"')
      )
      second = described_class.new(
        '--opt1', 'val1',
        opts.merge(quoting: "'")
      )

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when option placement different' do
      first = described_class.new(
        '--opt1', 'val1',
        opts.merge(placement: :after_command)
      )
      second = described_class.new(
        '--opt1', 'val1',
        opts.merge(placement: :after_subcommands)
      )

      expect(first.eql?(second)).to(be(false))
    end
  end

  describe '#hash' do
    let(:opts) do
      {
        separator: ' ',
        quoting: nil,
        placement: :after_command
      }
    end

    it 'has same hash when class and state equal' do
      first = described_class.new('--opt1', 'val1', opts)
      second = described_class.new('--opt1', 'val1', opts)

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash when class different' do
      first = Class.new(described_class).new('--opt1', 'val1', opts)
      second = described_class.new('--opt1', 'val1', opts)

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when option different' do
      first = described_class.new('--opt1', 'val1', opts)
      second = described_class.new('--opt2', 'val1', opts)

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when value different' do
      first = described_class.new('--opt1', 'val1', opts)
      second = described_class.new('--opt1', 'val2', opts)

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when option separator different' do
      first = described_class.new(
        '--opt1', 'val1',
        opts.merge(separator: ' ')
      )
      second = described_class.new(
        '--opt1', 'val1',
        opts.merge(separator: '=')
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when option quoting different' do
      first = described_class.new(
        '--opt1', 'val1',
        opts.merge(quoting: '"')
      )
      second = described_class.new(
        '--opt1', 'val1',
        opts.merge(quoting: "'")
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when option placement different' do
      first = described_class.new(
        '--opt1', 'val1',
        opts.merge(placement: :after_command)
      )
      second = described_class.new(
        '--opt1', 'val1',
        opts.merge(placement: :after_subcommands)
      )

      expect(first.hash).not_to(eq(second.hash))
    end
  end

  describe '#string' do
    it 'converts non-string option to string before returning' do
      option_class = Class.new do
        def to_s
          '--opt'
        end
      end
      option = option_class.new

      expect(described_class.new(option, 'val').string)
        .to(eq('--opt val'))
    end

    it 'converts non-string value to string before returning' do
      expect(described_class.new('--opt', true).string)
        .to(eq('--opt true'))
    end

    it 'uses space separator with no quoting by default' do
      expect(described_class.new('--opt', 'val').string)
        .to(eq('--opt val'))
    end

    it 'uses specified separator when provided' do
      expect(described_class
               .new('--opt', 'val', separator: ':')
               .string)
        .to(eq('--opt:val'))
    end

    it 'uses specified quoting when provided' do
      expect(described_class
               .new('--opt', 'val', quoting: '"')
               .string)
        .to(eq('--opt "val"'))
    end
  end

  describe '#array' do
    it 'returns option and value as separate items by default' do
      expect(described_class.new('--opt', 'val').array)
        .to(eq(%w[--opt val]))
    end

    it 'converts non-string option to string before using in array' do
      option_class = Class.new do
        def to_s
          '--opt'
        end
      end
      option = option_class.new

      expect(described_class.new(option, 'val').array)
        .to(eq(%w[--opt val]))
    end

    it 'converts non-string value to string before using in array' do
      expect(described_class.new('--opt', true).array)
        .to(eq(%w[--opt true]))
    end

    it 'returns option and value as single item with separator ' \
       'when non-space' do
      expect(described_class
               .new('--opt', 'val', separator: '=')
               .array)
        .to(eq(%w[--opt=val]))
    end

    it 'returns option and value as separate items when separator ' \
       'is space' do
      expect(described_class
               .new('--opt', 'val', separator: ' ')
               .array)
        .to(eq(%w[--opt val]))
    end

    it 'ignores quoting' do
      expect(described_class
               .new('--opt', 'val', quoting: '"')
               .array)
        .to(eq(%w[--opt val]))
    end
  end
end
