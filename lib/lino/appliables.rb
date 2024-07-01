# frozen_string_literal: true

require_relative 'construction'

module Lino
  module Appliables
    include Validation

    def with_appliable(appliable)
      return self if nil?(appliable)

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
