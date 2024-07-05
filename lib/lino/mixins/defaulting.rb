# frozen_string_literal: true

module Lino
  module Mixins
    module Defaulting
      private

      def or_nil(enumerable, key)
        enumerable.include?(key) ? enumerable[key] : nil
      end

      def or_nth(enumerable, key, index)
        enumerable.include?(key) ? enumerable[key] : enumerable[index]
      end
    end
  end
end
