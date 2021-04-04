# frozen_string_literal: true

require 'hamster'
require_relative 'utilities'
require_relative 'options'

module Lino
  class SubcommandBuilder
    include Lino::Utilities
    include Lino::Options

    class <<self
      def for_subcommand(subcommand)
        SubcommandBuilder.new(subcommand: subcommand)
      end
    end

    def initialize(subcommand: nil, options: [])
      @subcommand = subcommand
      @options = Hamster::Vector.new(options)
    end

    def build(option_separator, option_quoting)
      components = [
        @subcommand,
        map_and_join(
          @options,
          &(quote_with(option_quoting) >> join_with(option_separator))
        )
      ]
      components.reject(&:empty?).join(' ')
    end

    private

    def with(**replacements)
      SubcommandBuilder.new(**state.merge(replacements))
    end

    def state
      {
        subcommand: @subcommand,
        options: @options
      }
    end
  end
end
