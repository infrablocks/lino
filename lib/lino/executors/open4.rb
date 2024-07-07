# frozen_string_literal: true

require 'open4'

module Lino
  module Executors
    class Open4
      def execute(command_line, opts = {})
        opts = with_defaults(opts)

        ::Open4.spawn(
          command_line.env,
          *command_line.array,
          stdin: opts[:stdin],
          stdout: opts[:stdout],
          stderr: opts[:stderr],
          cwd: command_line.working_directory
        )
      end

      def ==(other)
        self.class == other.class
      end

      alias eql? ==

      def hash
        self.class.hash
      end

      private

      def with_defaults(opts)
        {
          stdin: opts[:stdin] || '',
          stdout: opts[:stdout] || $stdout,
          stderr: opts[:stderr] || $stderr
        }
      end
    end
  end
end
