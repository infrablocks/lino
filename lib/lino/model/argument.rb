# frozen_string_literal: true

module Lino
  module Model
    class Argument
      attr_reader :argument

      def initialize(argument)
        @argument = argument
      end

      def string
        argument.to_s
      end
      alias to_s string

      def array
        [argument.to_s]
      end
      alias to_a string

      def ==(other)
        self.class == other.class &&
          state == other.state
      end
      alias eql? ==

      def hash
        [self.class, state].hash
      end

      protected

      def state
        [
          @argument
        ]
      end
    end
  end
end
