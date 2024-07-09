# frozen_string_literal: true

module Lino
  module Model
    class Subcommand
      attr_reader :subcommand, :options

      def initialize(subcommand, opts = {})
        opts = with_defaults(opts)
        @subcommand = subcommand
        @options = Hamster::Vector.new(opts[:options])
      end

      def string
        [@subcommand.to_s, @options.map(&:string)].reject(&:empty?).join(' ')
      end
      alias to_s string

      def array
        [@subcommand.to_s, @options.map(&:array)].flatten
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
          @subcommand,
          @options
        ]
      end

      private

      def with_defaults(opts)
        {
          options: opts.fetch(:options, [])
        }
      end
    end
  end
end
