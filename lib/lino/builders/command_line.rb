# frozen_string_literal: true

require 'hamster'

require_relative 'mixins/state_boundary'
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
      include Mixins::StateBoundary
      include Mixins::Arguments
      include Mixins::EnvironmentVariables
      include Mixins::OptionConfig
      include Mixins::Options
      include Mixins::Subcommands
      include Mixins::Executor
      include Mixins::Appliables
      include Mixins::Validation

      def initialize(state)
        @command = state[:command]
        super
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

      def with(replacements)
        Builders::CommandLine.new(state.merge(replacements))
      end
    end
  end
end
