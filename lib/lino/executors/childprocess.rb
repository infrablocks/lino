# frozen_string_literal: true

require 'childprocess'

require_relative '../errors'

module Lino
  module Executors
    class Childprocess
      def execute(command_line, opts = {})
        process = ::ChildProcess.build(*command_line.array)

        set_output_streams(process, opts)
        set_environment(process, command_line.environment_variables)
        start_process(process, opts)

        exit_code = process.wait

        return unless exit_code != 0

        raise Lino::Errors::ExecutionError.new(
          command_line.string, exit_code
        )
      end

      private

      def start_process(process, opts)
        process.duplex = true if opts[:stdin]
        process.start
        process.io.stdin.write(opts[:stdin]) if opts[:stdin]
      end

      def set_output_streams(process, opts)
        process.io.inherit!
        process.io.stdout = opts[:stdout] if opts[:stdout]
        process.io.stderr = opts[:stderr] if opts[:stderr]
      end

      def set_environment(process, environment_variables)
        environment_variables.each do |environment_variable|
          process.environment[environment_variable.name] =
            environment_variable.value
        end
      end
    end
  end
end
