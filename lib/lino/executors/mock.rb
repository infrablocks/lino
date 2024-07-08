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
        execution = { command_line:, opts:, exit_code: @exit_code }
        execution = process_streams(execution, opts)

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

      private

      def process_streams(execution, opts)
        execution = process_stdout(execution, opts[:stdout])
        execution = process_stderr(execution, opts[:stderr])
        process_stdin(execution, opts[:stdin])
      end

      def process_stdout(execution, stdout)
        if stdout && stdout_contents
          stdout.write(stdout_contents)
          return execution.merge(stdout_contents:)
        end

        execution
      end

      def process_stderr(execution, stderr)
        if stderr && stderr_contents
          stderr.write(stderr_contents)
          return execution.merge(stderr_contents:)
        end

        execution
      end

      def process_stdin(execution, stdin)
        return execution.merge(stdin_contents: stdin.read) if stdin

        execution
      end
    end
  end
end
