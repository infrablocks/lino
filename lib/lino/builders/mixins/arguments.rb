# frozen_string_literal: true

require_relative 'validation'
require_relative '../../model'

module Lino
  module Builders
    module Mixins
      module Arguments
        include Validation

        def initialize(state)
          @arguments = Hamster::Vector.new(state[:arguments] || [])
          super
        end

        def with_argument(argument)
          return self if nil?(argument)
          return self if empty?(argument.to_s)

          with(arguments: @arguments.add(Model::Argument.new(argument)))
        end

        def with_arguments(arguments)
          return self if nil_or_empty?(arguments)

          arguments.inject(self) { |s, argument| s.with_argument(argument) }
        end
      end
    end
  end
end
