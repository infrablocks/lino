require 'hamster'
require_relative 'utilities'
require_relative 'command_line'
require_relative 'subcommand_builder'
require_relative 'switches'

module Lino
  class CommandLineBuilder
    include Lino::Utilities
    include Lino::Switches

    class <<self
      def for_command(command)
        CommandLineBuilder.new(command: command)
      end
    end

    def initialize(
      command: nil,
      subcommands: [],
      switches: [],
      arguments: [],
      environment_variables: [],
      option_separator: ' ',
      option_quoting: nil
    )
      @command = command
      @subcommands = Hamster::Vector.new(subcommands)
      @switches = Hamster::Vector.new(switches)
      @arguments = Hamster::Vector.new(arguments)
      @environment_variables = Hamster::Vector.new(environment_variables)
      @option_separator = option_separator
      @option_quoting = option_quoting
    end

    def with_subcommand(subcommand, &block)
      with(
        subcommands: @subcommands.add(
          (block || ->(sub) { sub }).call(
            SubcommandBuilder.for_subcommand(subcommand)
          )
        )
      )
    end

    def with_option_separator(option_separator)
      with(option_separator: option_separator)
    end

    def with_option_quoting(character)
      with(option_quoting: character)
    end

    def with_argument(argument)
      with(arguments: add_argument(argument))
    end

    def with_arguments(arguments)
      arguments.each { |argument| add_argument(argument) }
      with({})
    end

    def with_environment_variable(environment_variable, value)
      with(environment_variables: @environment_variables.add([environment_variable, value]))
    end

    def build
      components = [
        map_and_join(@environment_variables) do |var|
          "#{var[0]}=\"#{var[1].to_s.gsub(/"/, '\\"')}\""
        end,
        @command,
        map_and_join(
          @switches,
          &(quote_with(@option_quoting) >> join_with(@option_separator))
        ),
        map_and_join(@subcommands) do |sub|
          sub.build(@option_separator, @option_quoting)
        end,
        map_and_join(@arguments, &join_with(' '))
      ]

      command_string = components.reject(&:empty?).join(' ')

      CommandLine.new(command_string)
    end

    private

    def with(**replacements)
      CommandLineBuilder.new(**state.merge(replacements))
    end

    def state
      {
        command: @command,
        subcommands: @subcommands,
        switches: @switches,
        arguments: @arguments,
        environment_variables: @environment_variables,
        option_separator: @option_separator,
        option_quoting: @option_quoting
      }
    end

    def add_argument(argument)
      return @arguments if missing?(argument)

      @arguments = @arguments.add({ components: [argument] })
    end
  end
end
