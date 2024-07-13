# frozen_string_literal: true

require_relative 'validation'

module Lino
  module Builders
    module Mixins
      module Appliables
        include Validation

        def with_appliable(appliable)
          return self if appliable.nil?

          appliable.apply(self)
        end

        def with_appliables(appliables)
          return self if nil_or_empty?(appliables)

          appliables.inject(self) do |s, appliable|
            s.with_appliable(appliable)
          end
        end
      end
    end
  end
end
