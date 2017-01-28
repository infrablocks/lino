require 'open4'

module Lino
  class CommandLine
    def initialize command_line
      @command_line = command_line
    end

    def execute(
        stdin: '',
        stdout: STDOUT,
        stderr: STDERR)
      Open4::spawn(
          @command_line,
          stdin: stdin,
          stdout: stdout,
          stderr: stderr)
    end

    def to_s
      @command_line
    end
  end
end