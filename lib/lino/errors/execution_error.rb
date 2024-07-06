# frozen_string_literal: true

module Lino
  module Errors
    class ExecutionError < StandardError
      def initialize(
        command_line = nil,
        exit_code = nil,
        cause = nil
      )
        @command_line = command_line
        @exit_code = exit_code
        @cause = cause
        super('Failed while executing command line.')
      end
    end
  end
end
