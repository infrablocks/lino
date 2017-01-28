module Lino
  class CommandLine
    def initialize command_line
      @command_line = command_line
    end

    def to_s
      @command_line
    end
  end
end