# frozen_string_literal: true

require 'hamster'

require_relative 'mixins/appliables'
require_relative 'mixins/arguments'
require_relative 'mixins/environment_variables'
require_relative 'mixins/option_config'
require_relative 'mixins/options'
require_relative 'mixins/subcommands'
require_relative 'mixins/executor'
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
      include Mixins::Executor
      include Mixins::Validation

      def initialize(state)
        state = with_defaults(state)
        initialize_components(state)
        initialize_option_config(state)
        initialize_executor(state)
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
        component_state
          .merge(option_config_state)
          .merge(executor_state)
      end

      private

      def component_state
        {
          command: @command,
          subcommands: @subcommands,
          options: @options,
          arguments: @arguments,
          environment_variables: @environment_variables
        }
      end

      def option_config_state
        {
          option_separator: @option_separator,
          option_quoting: @option_quoting,
          option_placement: @option_placement
        }
      end

      def executor_state
        { executor: @executor }
      end

      def initialize_components(state)
        @command = state[:command]
        @subcommands = Hamster::Vector.new(state[:subcommands])
        @options = Hamster::Vector.new(state[:options])
        @arguments = Hamster::Vector.new(state[:arguments])
        @environment_variables =
          Hamster::Vector.new(state[:environment_variables])
      end

      def initialize_option_config(state)
        @option_separator = state[:option_separator]
        @option_quoting = state[:option_quoting]
        @option_placement = state[:option_placement]
      end

      def initialize_executor(state)
        @executor = state[:executor]
      end

      def with_defaults(state)
        state.merge(component_defaults(state))
             .merge(option_config_defaults(state))
             .merge(executor_defaults(state))
      end

      def component_defaults(state)
        {
          subcommands: state[:subcommands] || [],
          options: state[:options] || [],
          arguments: state[:arguments] || [],
          environment_variables: state[:environment_variables] || []
        }
      end

      def option_config_defaults(state)
        {
          option_separator: state[:option_separator] || ' ',
          option_placement: state[:option_placement] || :after_command
        }
      end

      def executor_defaults(state)
        { executor: state[:executor] || Executors::Childprocess.new }
      end

      def with(replacements)
        Builders::CommandLine.new(state.merge(replacements))
      end
    end
  end
end
