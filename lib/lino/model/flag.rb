# frozen_string_literal: true

module Lino
  module Model
    class Flag
      attr_reader :flag,
                  :placement

      def initialize(flag, opts = {})
        opts = with_defaults(opts)
        @flag = flag
        @placement = opts[:placement]
      end

      def string
        flag
      end
      alias to_s string

      def array
        [flag]
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
          @flag,
          @placement
        ]
      end

      private

      def with_defaults(opts)
        {
          placement: opts[:placement] || :after_command
        }
      end
    end
  end
end
