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

    def with_option(switch, value)
      with(switches: @switches.add([switch, value]))
    end

    def with_option_separator(option_separator)
      with(option_separator: option_separator)
    end

    def with_flag(flag)
      with(switches: @switches.add([flag]))
    end

    def with_argument(argument)
      with(arguments: @arguments.add([argument]))
    end

    def with_environment_variable(environment_variable, value)
      with(environment_variables: @environment_variables.add([environment_variable, value]))
    end

    def build
      components = [
          map_and_join(@environment_variables) { |var| "#{var[0]}=\"#{var[1]}\"" },
          @command,
          map_and_join(@switches, &join_with(@option_separator)),
          map_and_join(@arguments, &join_with(' '))
      ]

      command_string = components
          .reject { |item| item.empty? }
          .join(' ')

      CommandLine.new(command_string)
    end

    private

    def with **replacements
      CommandLineBuilder.new(**state.merge(replacements))
    end

    def state
      {
          command: @command,
          switches: @switches,
          arguments: @arguments,
          environment_variables: @environment_variables,
          option_separator: @option_separator
      }
    end

    def map_and_join(collection, &block)
      collection.map { |item| block.call(item) }.join(' ')
    end

    def join_with(separator)
      lambda { |item| item.join(separator) }
    end
  end
end