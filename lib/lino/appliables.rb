# frozen_string_literal: true

require_relative 'utilities'

module Lino
  module Appliables
    include Lino::Utilities

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
