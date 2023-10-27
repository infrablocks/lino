# frozen_string_literal: true

require 'hamster'
require_relative 'utilities'
require_relative 'command_line'
require_relative 'subcommand_builder'
require_relative 'options'
require_relative 'appliables'

module Lino
  # rubocop:disable Metrics/ClassLength
  class CommandLineBuilder
    include Lino::Utilities
    include Lino::Options
    include Lino::Appliables

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
      return self if nil?(subcommand)

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
      return self if nil?(argument)

      with(arguments: @arguments.add({ components: [argument] }))
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
      components = formatted_components
      command_line =
        component_paths
        .collect { |path| path.inject(components) { |c, p| c && c[p] } }
        .reject(&:empty?)
        .join(' ')

      CommandLine.new(command_line)
    end

    private

    def component_paths
      [
        %i[environment_variables],
        %i[command],
        %i[options after_command],
        %i[subcommands],
        %i[options after_subcommands],
        %i[arguments],
        %i[options after_arguments]
      ]
    end

    def formatted_components
      {
        environment_variables: formatted_environment_variables,
        command: @command,
        options: formatted_options,
        subcommands: formatted_subcommands,
        arguments: formatted_arguments
      }
    end

    def formatted_environment_variables
      map_and_join(@environment_variables) do |var|
        "#{var[0]}=\"#{var[1].to_s.gsub('"', '\\"')}\""
      end
    end

    def formatted_options_with_placement(placement)
      map_and_join(
        options_with_placement(placement),
        &(quote_with(@option_quoting) >> join_with(@option_separator))
      )
    end

    def formatted_options
      %i[
        after_command
        after_subcommands
        after_arguments
      ].inject({}) do |options, placement|
        options
          .merge({ placement => formatted_options_with_placement(placement) })
      end
    end

    def formatted_subcommands
      map_and_join(@subcommands) do |sub|
        sub.build(@option_separator, @option_quoting)
      end
    end

    def formatted_arguments
      map_and_join(
        @arguments,
        &join_with(' ')
      )
    end

    def options_with_placement(placement)
      @options.select { |o| o[:placement] == placement } +
        if @option_placement == placement
          @options.select { |o| o[:placement].nil? }
        end
    end

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
