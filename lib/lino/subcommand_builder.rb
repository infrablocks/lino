# frozen_string_literal: true

require 'hamster'
require_relative 'subcommand'
require_relative 'options'
require_relative 'appliables'

module Lino
  class SubcommandBuilder
    include Options
    include Appliables

    class << self
      def for_subcommand(subcommand)
        SubcommandBuilder.new(subcommand: subcommand)
      end
    end

    def initialize(subcommand: nil, options: [])
      @subcommand = subcommand
      @options = Hamster::Vector.new(options)
    end

    def build(option_separator, option_quoting)
      Subcommand.new(
        @subcommand,
        state.merge(
          option_separator: option_separator,
          option_quoting: option_quoting
        )
      )
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
