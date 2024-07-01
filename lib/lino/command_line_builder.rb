# frozen_string_literal: true

require 'hamster'
require_relative 'validation'
require_relative 'command_line'
require_relative 'subcommand_builder'
require_relative 'options'
require_relative 'appliables'

module Lino
  # rubocop:disable Metrics/ClassLength
  class CommandLineBuilder
    include Validation
    include Options
    include Appliables

    class << self
      def for_command(command)
        CommandLineBuilder.new(command: command)
      end
    end

    # rubocop:disable Metrics/ParameterLists
    def initialize(
      command: nil,
      subcommands: [],
      options: [],
      arguments: [],
      environment_variables: [],
      option_separator: ' ',
      option_quoting: nil,
      option_placement: :after_command
    )
      @command = command
      @subcommands = Hamster::Vector.new(subcommands)
      @options = Hamster::Vector.new(options)
      @arguments = Hamster::Vector.new(arguments)
      @environment_variables = Hamster::Vector.new(environment_variables)
      @option_separator = option_separator
      @option_quoting = option_quoting
      @option_placement = option_placement
    end
    # rubocop:enable Metrics/ParameterLists

    def with_subcommand(subcommand, &block)
      return self if nil_or_empty?(subcommand)

      with(
        subcommands: @subcommands.add(
          (block || ->(sub) { sub }).call(
            SubcommandBuilder.for_subcommand(subcommand)
          )
        )
      )
    end

    def with_subcommands(subcommands, &block)
      return self if nil_or_empty?(subcommands)

      without_block = subcommands[0...-1]
      with_block = subcommands.last

      without_block
        .inject(self) { |s, sc| s.with_subcommand(sc) }
        .with_subcommand(with_block, &block)
    end

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

    def with_argument(argument)
      return self if nil_or_empty?(argument.to_s)

      with(arguments: @arguments.add({ components: [argument.to_s] }))
    end

    def with_arguments(arguments)
      return self if nil_or_empty?(arguments)

      arguments.inject(self) { |s, argument| s.with_argument(argument) }
    end

    def with_environment_variable(environment_variable, value)
      with(
        environment_variables:
          @environment_variables.add(
            [
              environment_variable, value
            ]
          )
      )
    end

    def with_environment_variables(environment_variables)
      return self if nil_or_empty?(environment_variables)

      environment_variables.entries.inject(self) do |s, var|
        s.with_environment_variable(
          var.include?(:name) ? var[:name] : var[0],
          var.include?(:value) ? var[:value] : var[1]
        )
      end
    end

    def build
      CommandLine.new(
        @command,
        state.merge(
          subcommands: @subcommands.map do |s|
            s.build(@option_separator, @option_quoting)
          end
        )
      )
    end

    private

    def with(**replacements)
      CommandLineBuilder.new(**state.merge(replacements))
    end

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
  end
  # rubocop:enable Metrics/ClassLength
end
