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
        execution = Execution.new(command_line:, opts:, exit_code: @exit_code)
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
          return execution.with_stdout_contents(stdout_contents)
        end

        execution
      end

      def process_stderr(execution, stderr)
        if stderr && stderr_contents
          stderr.write(stderr_contents)
          return execution.with_stderr_contents(stderr_contents)
        end

        execution
      end

      def process_stdin(execution, stdin)
        return execution.with_stdin_contents(stdin.read) if stdin

        execution
      end

      class Execution
        attr_reader :command_line,
                    :opts,
                    :exit_code,
                    :stdin_contents,
                    :stdout_contents,
                    :stderr_contents

        def initialize(state)
          @command_line = state[:command_line]
          @opts = state[:opts]
          @exit_code = state[:exit_code]
          @stdin_contents = state[:stdin_contents]
          @stdout_contents = state[:stdout_contents]
          @stderr_contents = state[:stderr_contents]
        end

        def with_stdin_contents(contents)
          Execution.new(state_hash.merge(stdin_contents: contents))
        end

        def with_stdout_contents(contents)
          Execution.new(state_hash.merge(stdout_contents: contents))
        end

        def with_stderr_contents(contents)
          Execution.new(state_hash.merge(stderr_contents: contents))
        end

        def ==(other)
          self.class == other.class &&
            state_array == other.state_array
        end

        alias eql? ==

        def hash
          [self.class, state_array].hash
        end

        protected

        def state_array
          [
            @command_line,
            @opts,
            @exit_code,
            @stdin_contents,
            @stdout_contents,
            @stderr_contents
          ]
        end

        def state_hash
          {
            command_line: @command_line,
            opts: @opts,
            exit_code: @exit_code,
            stdin_contents: @stdin_contents,
            stdout_contents: @stdout_contents,
            stderr_contents: @stderr_contents
          }
        end
      end
    end
  end
end
