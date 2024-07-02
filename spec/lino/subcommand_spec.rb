# frozen_string_literal: true

require 'spec_helper'

describe Lino::Subcommand do
  describe '#==' do
    it 'returns true when class and state equal' do
      first = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first == second).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(Lino::Subcommand).new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first == second).to(be(false))
    end

    it 'returns false when subcommand different' do
      first = described_class.new(
        'sub1',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub2',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first == second).to(be(false))
    end

    it 'returns false when options different' do
      first = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt2 val2] }
        ]
      )

      expect(first == second).to(be(false))
    end

    it 'returns false when option separator different' do
      first = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: '=',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first == second).to(be(false))
    end

    it 'returns false when option quoting different' do
      first = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: '"',
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: "'",
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first == second).to(be(false))
    end
  end

  describe '#eql?' do
    it 'returns true when class and state equal' do
      first = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first.eql?(second)).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(Lino::Subcommand).new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when subcommand different' do
      first = described_class.new(
        'sub1',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub2',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when options different' do
      first = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt2 val2] }
        ]
      )

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when option separator different' do
      first = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: '=',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when option quoting different' do
      first = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: '"',
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: "'",
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first.eql?(second)).to(be(false))
    end
  end

  describe '#hash' do
    it 'hash same hash when class and state equal' do
      first = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash when class different' do
      first = Class.new(Lino::Subcommand).new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when subcommand different' do
      first = described_class.new(
        'sub1',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub2',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when options different' do
      first = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt2 val2] }
        ]
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when option separator different' do
      first = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: '=',
        option_quoting: nil,
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when option quoting different' do
      first = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: '"',
        options: [
          { components: %w[--opt1 val1] }
        ]
      )
      second = described_class.new(
        'sub',
        option_separator: ' ',
        option_quoting: "'",
        options: [
          { components: %w[--opt1 val1] }
        ]
      )

      expect(first.hash).not_to(eq(second.hash))
    end
  end
end
