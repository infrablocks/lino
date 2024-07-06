# frozen_string_literal: true

module Lino
  module Model
    class Option
      attr_reader :option,
                  :value,
                  :separator,
                  :quoting,
                  :placement

      def initialize(option, value, opts = {})
        opts = with_defaults(opts)
        @option = option
        @value = value
        @separator = opts[:separator]
        @quoting = opts[:quoting]
        @placement = opts[:placement]
      end

      def quoted_value
        "#{quoting}#{value}#{quoting}"
      end

      def string
        "#{option}#{separator}#{quoted_value}"
      end
      alias to_s string

      def array
        if separator == ' '
          [option, value]
        else
          ["#{option}#{separator}#{value}"]
        end
      end
      alias to_a array

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
          @option,
          @value,
          @separator,
          @quoting,
          @placement
        ]
      end

      private

      def with_defaults(opts)
        {
          separator: opts[:separator] || ' ',
          quoting: opts[:quoting],
          placement: opts[:placement] || :after_command
        }
      end
    end
  end
end
