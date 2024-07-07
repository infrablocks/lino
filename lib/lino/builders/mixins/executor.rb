# frozen_string_literal: true

module Lino
  module Builders
    module Mixins
      module Executor
        def initialize(state)
          @executor = state[:executor] || Executors::Childprocess.new
          super
        end

        def with_executor(executor)
          with(executor: executor)
        end

        private

        def state
          super.merge(executor: @executor)
        end
      end
    end
  end
end
