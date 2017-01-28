require 'hamster'
require_relative 'command_line'

module Lino
  class CommandLineBuilder
    class <<self
      def for_command command
        CommandLineBuilder.new(command: command)
      end
    end

    def initialize(
        command: nil,
        switches: [],
        arguments: [],
        environment_variables: [],
        option_separator: ' ')
      @command = command
      @switches = Hamster::Vector.new(switches)
      @arguments = Hamster::Vector.new(arguments)
      @environment_variables = Hamster::Vector.new(environment_variables)
      @option_separator = option_separator
    end

    def with_option switch, value
      CommandLineBuilder.new(
          command: @command,
          switches: @switches.add([switch, value]),
          arguments: @arguments,
          environment_variables: @environment_variables,
          option_separator: @option_separator)
    end

    def with_option_separator option_separator
      CommandLineBuilder.new(
          command: @command,
          switches: @switches,
          arguments: @arguments,
          environment_variables: @environment_variables,
          option_separator: option_separator)
    end

    def with_flag flag
      CommandLineBuilder.new(
          command: @command,
          switches: @switches.add([flag]),
          arguments: @arguments,
          environment_variables: @environment_variables,
          option_separator: @option_separator)
    end

    def with_argument argument
      CommandLineBuilder.new(
          command: @command,
          switches: @switches,
          arguments: @arguments.add([argument]),
          environment_variables: @environment_variables,
          option_separator: @option_separator)
    end

    def with_environment_variable environment_variable, value
      CommandLineBuilder.new(
          command: @command,
          switches: @switches,
          arguments: @arguments,
          environment_variables: @environment_variables.add([environment_variable, value]),
          option_separator: @option_separator)
    end

    def build
      components = [
          @environment_variables.map { |var| "#{var[0]}=\"#{var[1]}\"" }.join(' '),
          @command,
          @switches.map { |switch| switch.join(@option_separator) }.join(' '),
          @arguments.map { |argument| argument.join(' ') }.join(' ')
      ]

      command_string = components
          .reject { |item| item.empty? }
          .join(' ')

      CommandLine.new(command_string)
    end
  end
end