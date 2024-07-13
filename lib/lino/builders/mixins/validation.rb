# frozen_string_literal: true

module Lino
  module Builders
    module Mixins
      module Validation
        def empty?(value)
          value.respond_to?(:empty?) && value.empty?
        end

        def nil_or_empty?(value)
          value.nil? || empty?(value)
        end
      end
    end
  end
end
