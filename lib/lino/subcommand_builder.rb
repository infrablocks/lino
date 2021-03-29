require 'hamster'
require_relative 'utilities'
require_relative 'option_flag_mixin'

module Lino
  class SubcommandBuilder
    include Lino::Utilities
    include Lino::OptionFlagMixin

    class <<self
      def for_subcommand(subcommand)
        SubcommandBuilder.new(subcommand: subcommand)
      end
    end

    def initialize(subcommand: nil, switches: [])
      @subcommand = subcommand
      @switches = Hamster::Vector.new(switches)
    end

    def build(option_separator, option_quoting)
      components = [
        @subcommand,
        map_and_join(
          @switches,
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
        switches: @switches
      }
    end
  end
end
