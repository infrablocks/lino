# frozen_string_literal: true

require 'open4'

module Lino
  module Executors
    class Open4
      def execute(command_line, opts = {})
        stdin = opts[:stdin] || ''
        stdout = opts[:stdout] || $stdout
        stderr = opts[:stderr] || $stderr

        ::Open4.spawn(
          command_line.env,
          *command_line.array,
          stdin: stdin,
          stdout: stdout,
          stderr: stderr
        )
      end
    end
  end
end
