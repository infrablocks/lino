# frozen_string_literal: true

require 'hamster'

require_relative 'mixins/appliables'
require_relative 'mixins/arguments'
require_relative 'mixins/environment_variables'
require_relative 'mixins/executor'
require_relative 'mixins/option_config'
require_relative 'mixins/options'
require_relative 'mixins/state_boundary'
require_relative 'mixins/subcommands'
require_relative 'mixins/validation'
require_relative 'mixins/working_directory'
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
      include Mixins::WorkingDirectory
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
            options: build_options(@option_separator, @option_quoting,
                                   @option_placement),
            subcommands: build_subcommands(@option_separator, @option_quoting,
                                           @option_placement)
          )
        )
      end

      protected

      def state
        super.merge(command: @command)
      end

      private

      def with(replacements)
        Builders::CommandLine.new(state.merge(replacements))
      end
    end
  end
end
