require 'open4'

module Lino
  class CommandLine
    def initialize command_line
      @command_line = command_line
    end

    def execute
      Open4::spawn(
          @command_line,
          stdin: '',
          stdout: STDOUT,
          stderr: STDERR)
    end

    def to_s
      @command_line
    end
  end
end