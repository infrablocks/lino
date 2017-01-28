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
        option_separator: ' ')
      @command = command
      @switches = Hamster::Vector.new(switches)
      @arguments = Hamster::Vector.new(arguments)
      @option_separator = option_separator
    end

    def with_option switch, value
      CommandLineBuilder.new(
          command: @command,
          switches: @switches.add([switch, value]),
          arguments: @arguments,
          option_separator: @option_separator)
    end

    def with_option_separator option_separator
      CommandLineBuilder.new(
          command: @command,
          switches: @switches,
          arguments: @arguments,
          option_separator: option_separator)
    end

    def with_flag flag
      CommandLineBuilder.new(
          command: @command,
          switches: @switches.add([flag]),
          arguments: @arguments,
          option_separator: @option_separator)
    end

    def with_argument argument
      CommandLineBuilder.new(
          command: @command,
          switches: @switches,
          arguments: @arguments.add([argument]),
          option_separator: @option_separator)
    end

    def build
      components = [
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