# frozen_string_literal: true

module Lino
  module Builders
    module Mixins
      module Executor
        def initialize(state)
          super
          @executor = state[:executor] || Lino.configuration.executor
        end

        def with_executor(executor)
          with(executor:)
        end

        private

        def state
          super.merge(executor: @executor)
        end
      end
    end
  end
end
