module Lino
  module Utilities
    def map_and_join(collection, &block)
      collection.map { |item| block.call(item) }.join(' ')
    end

    def join_with(separator)
      lambda { |item| item.join(separator) }
    end
  end
end