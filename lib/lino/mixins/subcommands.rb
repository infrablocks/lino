# frozen_string_literal: true

require_relative 'validation'
require_relative '../subcommand_builder'

module Lino
  module Mixins
    module Subcommands
      include Validation

      def with_subcommand(subcommand, &block)
        return self if nil_or_empty?(subcommand)

        with(
          subcommands: @subcommands.add(
            (block || ->(sub) { sub }).call(
              SubcommandBuilder.for_subcommand(subcommand)
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
