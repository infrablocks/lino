# frozen_string_literal: true

module Lino
  module Builders
    module Mixins
      module WorkingDirectory
        def initialize(state)
          @working_directory = state[:working_directory]
          super
        end

        def with_working_directory(working_directory)
          with(working_directory: working_directory)
        end

        private

        def state
          super.merge(working_directory: @working_directory)
        end
      end
    end
  end
end
