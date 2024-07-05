# frozen_string_literal: true

module Lino
  module Mixins
    module OptionConfig
      def with_option_separator(option_separator)
        with(option_separator: option_separator)
      end

      def with_option_quoting(character)
        with(option_quoting: character)
      end

      def with_option_placement(option_placement)
        with(option_placement: option_placement)
      end

      def with_options_after_command
        with_option_placement(:after_command)
      end

      def with_options_after_subcommands
        with_option_placement(:after_subcommands)
      end

      def with_options_after_arguments
        with_option_placement(:after_arguments)
      end
    end
  end
end
