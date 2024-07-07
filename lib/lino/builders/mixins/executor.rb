# frozen_string_literal: true

module Lino
  module Builders
    module Mixins
      module Executor
        def with_executor(executor)
          with(executor: executor)
        end
      end
    end
  end
end
