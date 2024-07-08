# frozen_string_literal: true

module Lino
  module Executors
    class Mock
      attr_reader :executions, :stdout_contents, :stderr_contents
      attr_accessor :exit_code

      def initialize
        reset
      end

      def execute(command_line, opts = {})
        stdin = opts[:stdin]
        stdout = opts[:stdout]
        stderr = opts[:stderr]

        execution = { command_line:, opts:, exit_code: @exit_code }

        if stdout && stdout_contents
          execution[:stdout_contents] = stdout_contents
          stdout.write(stdout_contents)
        end

        if stderr && stderr_contents
          execution[:stderr_contents] = stderr_contents
          stderr.write(stderr_contents)
        end

        if stdin
          execution[:stdin_contents] = stdin.read
        end

        @executions << execution

        return if @exit_code.zero?

        raise Lino::Errors::ExecutionError.new(
          command_line.string, @exit_code
        )
      end

      def fail_all_executions
        self.exit_code = 1
      end

      def write_to_stdout(contents)
        @stdout_contents = contents
      end

      def write_to_stderr(contents)
        @stderr_contents = contents
      end

      def reset
        @executions = []
        @exit_code = 0
        @stdout_contents = nil
        @stderr_contents = nil
      end
    end
  end
end
