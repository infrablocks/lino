require 'hamster'
require_relative 'utilities'

module Lino
  class SubcommandBuilder
    include Lino::Utilities

    class <<self
      def for_subcommand subcommand
        SubcommandBuilder.new(subcommand: subcommand)
      end
    end

    def initialize(
        subcommand: nil,
        switches: [])
      @subcommand = subcommand
      @switches = Hamster::Vector.new(switches)
    end

    def with_option(switch, value, separator: nil)
      with(switches: @switches.add({components: [switch, value], separator: separator}))
    end

    def with_flag(flag)
      with(switches: @switches.add({components: [flag]}))
    end

    def build(option_separator)
      components = [
          @subcommand,
          map_and_join(@switches, &join_with(option_separator))
      ]

      components
          .reject { |item| item.empty? }
          .join(' ')
    end

    private

    def with **replacements
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