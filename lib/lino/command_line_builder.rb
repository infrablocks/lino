# frozen_string_literal: true

require 'hamster'
require_relative 'command_line'

require_relative 'mixins/validation'
require_relative 'mixins/options'
require_relative 'mixins/option_config'
require_relative 'mixins/appliables'
require_relative 'mixins/arguments'
require_relative 'mixins/subcommands'
require_relative 'mixins/environment_variables'

module Lino
  class CommandLineBuilder
    class << self
      def for_command(command)
        CommandLineBuilder.new(command: command)
      end
    end

    include Mixins::Validation
    include Mixins::Options
    include Mixins::OptionConfig
    include Mixins::Appliables
    include Mixins::Arguments
    include Mixins::Subcommands
    include Mixins::EnvironmentVariables

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
      CommandLine.new(
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
      CommandLineBuilder.new(state.merge(replacements))
    end
  end
end
