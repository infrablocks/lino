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
        option_separator: ' ')
      @command = command
      @switches = Hamster::Vector.new(switches)
      @option_separator = option_separator
    end

    def with_option switch, value
      CommandLineBuilder.new(
          command: @command,
          switches: @switches.add([switch, value]),
          option_separator: @option_separator)
    end

    def with_option_separator option_separator
      CommandLineBuilder.new(
          command: @command,
          switches: @switches,
          option_separator: option_separator)
    end

    def with_flag flag
      CommandLineBuilder.new(
          command: @command,
          switches: @switches.add([flag]),
          option_separator: @option_separator)
    end

    def build
      components = [
          @command,
          @switches.map { |switch| switch.join(@option_separator) }.join(' ')
      ]

      command_string = components
          .reject { |item| item.empty? }
          .join(' ')

      CommandLine.new(command_string)
    end
  end
end