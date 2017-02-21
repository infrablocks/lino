module Lino
  module Utilities
    def map_and_join(collection, &block)
      collection.map { |item| block.call(item) }.join(' ')
    end

    def join_with(separator)
      lambda { |item| item[:components].join(item[:separator] || separator) }
    end
  end
end