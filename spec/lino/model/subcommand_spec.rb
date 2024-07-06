# frozen_string_literal: true

require 'spec_helper'

describe Lino::Model::Subcommand do
  describe '#==' do
    let(:opts) do
      {
        options: [
          Lino::Model::Option.new('--opt1', 'val1')
        ]
      }
    end

    it 'returns true when class and state equal' do
      first = described_class.new('sub', opts)
      second = described_class.new('sub', opts)

      expect(first == second).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(described_class).new('sub', opts)
      second = described_class.new('sub', opts)

      expect(first == second).to(be(false))
    end

    it 'returns false when subcommand different' do
      first = described_class.new('sub1', opts)
      second = described_class.new('sub2', opts)

      expect(first == second).to(be(false))
    end

    it 'returns false when options different' do
      first = described_class.new(
        'sub',
        opts.merge(
          options: [
            Lino::Model::Option.new('--opt1', 'val1')
          ]
        )
      )
      second = described_class.new(
        'sub',
        opts.merge(
          options: [
            Lino::Model::Option.new('--opt2', 'val2')
          ]
        )
      )

      expect(first == second).to(be(false))
    end
  end

  describe '#eql?' do
    let(:opts) do
      {
        options: [
          Lino::Model::Option.new('--opt1', 'val1')
        ]
      }
    end

    it 'returns true when class and state equal' do
      first = described_class.new('sub', opts)
      second = described_class.new('sub', opts)

      expect(first.eql?(second)).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(described_class).new('sub', opts)
      second = described_class.new('sub', opts)

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when subcommand different' do
      first = described_class.new('sub1', opts)
      second = described_class.new('sub2', opts)

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when options different' do
      first = described_class.new(
        'sub',
        opts.merge(
          options: [
            Lino::Model::Option.new('--opt1', 'val1')
          ]
        )
      )
      second = described_class.new(
        'sub',
        opts.merge(
          options: [
            Lino::Model::Option.new('--opt2', 'val2')
          ]
        )
      )

      expect(first.eql?(second)).to(be(false))
    end
  end

  describe '#hash' do
    let(:opts) do
      {
        options: [
          Lino::Model::Option.new('--opt1', 'val1')
        ]
      }
    end

    it 'has same hash when class and state equal' do
      first = described_class.new('sub', opts)
      second = described_class.new('sub', opts)

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash when class different' do
      first = Class.new(described_class).new('sub', opts)
      second = described_class.new('sub', opts)

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when subcommand different' do
      first = described_class.new('sub1', opts)
      second = described_class.new('sub2', opts)

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when options different' do
      first = described_class.new(
        'sub',
        opts.merge(
          options: [
            Lino::Model::Option.new('--opt1', 'val1')
          ]
        )
      )
      second = described_class.new(
        'sub',
        opts.merge(
          options: [
            Lino::Model::Option.new('--opt2', 'val2')
          ]
        )
      )

      expect(first.hash).not_to(eq(second.hash))
    end
  end
end
