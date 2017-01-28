require_relative 'command_line'

module Lino
  class CommandLineBuilder
    class <<self
      def for_command command
        CommandLineBuilder.new(command: command)
      end
    end

    def initialize(command: nil)
      @command = command
    end

    def build
      CommandLine.new(@command)
    end
  end
end