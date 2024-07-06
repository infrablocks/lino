# frozen_string_literal: true

module Lino
  module Builders
    module Mixins
      module Validation
        def nil?(value)
          value.nil?
        end

        def empty?(value)
          value.respond_to?(:empty?) && value.empty?
        end

        def nil_or_empty?(value)
          nil?(value) || empty?(value)
        end
      end
    end
  end
end
