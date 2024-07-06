# frozen_string_literal: true

require 'hamster'

require_relative 'mixins/appliables'
require_relative 'mixins/arguments'
require_relative 'mixins/environment_variables'
require_relative 'mixins/option_config'
require_relative 'mixins/options'
require_relative 'mixins/subcommands'
require_relative 'mixins/validation'
require_relative '../model'

module Lino
  module Builders
    class CommandLine
      include Mixins::Appliables
      include Mixins::Arguments
      include Mixins::EnvironmentVariables
      include Mixins::OptionConfig
      include Mixins::Options
      include Mixins::Subcommands
      include Mixins::Validation

      def initialize(state)
        @command = state[:command]
        @subcommands = Hamster::Vector.new(state[:subcommands] || [])
        @options = Hamster::Vector.new(state[:options] || [])
        @arguments = Hamster::Vector.new(state[:arguments] || [])
        @environment_variables =
          Hamster::Vector.new(state[:environment_variables] || [])
        @option_separator = state[:option_separator] || ' '
        @option_quoting = state[:option_quoting]
        @option_placement = state[:option_placement] || :after_command
      end

      def build
        Model::CommandLine.new(
          @command,
          state.merge(
            options: build_options,
            subcommands: build_subcommands
          )
        )
      end

      protected

      def state
        {
          command: @command,
          subcommands: @subcommands,
          options: @options,
          arguments: @arguments,
          environment_variables: @environment_variables,
          option_separator: @option_separator,
          option_quoting: @option_quoting,
          option_placement: @option_placement
        }
      end

      private

      def with(replacements)
        Builders::CommandLine.new(state.merge(replacements))
      end
    end
  end
end
