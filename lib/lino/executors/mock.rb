# frozen_string_literal: true

module Lino
  module Executors
    class Mock
      attr_reader :calls
      attr_accessor :exit_code

      def initialize
        reset
      end

      def execute(command_line, opts = {})
        @calls << { command_line:, opts:, exit_code: @exit_code }

        return if @exit_code.zero?

        raise Lino::Errors::ExecutionError.new(
          command_line.string, @exit_code
        )
      end

      def reset
        @calls = []
        @exit_code = 0
      end
    end
  end
end
