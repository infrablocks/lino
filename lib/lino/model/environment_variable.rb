# frozen_string_literal: true

require 'shellwords'

module Lino
  module Model
    class EnvironmentVariable
      attr_reader :name,
                  :value,
                  :quoting

      def initialize(name, value, opts = {})
        opts = with_defaults(opts)
        @name = name
        @value = value
        @quoting = opts[:quoting]
      end

      def quoted_value
        "#{quoting}#{value.to_s.gsub(quoting.to_s, "\\#{quoting}")}#{quoting}"
      end

      def string
        "#{name}=#{quoted_value}"
      end
      alias to_s string

      def array
        [name, value]
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
          @name,
          @value,
          @quoting
        ]
      end

      private

      def with_defaults(opts)
        {
          quoting: opts[:quoting] || '"'
        }
      end
    end
  end
end
