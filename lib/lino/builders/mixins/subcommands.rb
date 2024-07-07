# frozen_string_literal: true

require_relative 'validation'
require_relative '../../model'

module Lino
  module Builders
    module Mixins
      module Subcommands
        include Validation

        def initialize(state)
          @subcommands = Hamster::Vector.new(state[:subcommands] || [])
          super
        end

        def with_subcommand(subcommand, &block)
          return self if nil_or_empty?(subcommand)

          with(
            subcommands: @subcommands.add(
              (block || ->(sub) { sub }).call(
                Builders::Subcommand.for_subcommand(subcommand)
              )
            )
          )
        end

        def with_subcommands(subcommands, &block)
          return self if nil_or_empty?(subcommands)

          without_block = subcommands[0...-1]
          with_block = subcommands.last

          without_block
            .inject(self) { |s, sc| s.with_subcommand(sc) }
            .with_subcommand(with_block, &block)
        end

        private

        def build_subcommands
          @subcommands.map(&:build)
        end
      end
    end
  end
end
