# frozen_string_literal: true

require_relative 'validation'
require_relative '../argument'

module Lino
  module Mixins
    module Arguments
      include Validation

      def with_argument(argument)
        return self if nil_or_empty?(argument.to_s)

        with(arguments: @arguments.add(Argument.new(argument.to_s)))
      end

      def with_arguments(arguments)
        return self if nil_or_empty?(arguments)

        arguments.inject(self) { |s, argument| s.with_argument(argument) }
      end
    end
  end
end
