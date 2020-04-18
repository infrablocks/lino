require 'pp'

module Lino
  module Utilities
    def map_and_join(collection, &block)
      collection.map { |item| block.call(item) }.join(' ')
    end

    def join_with(global_separator)
      lambda do |item|
        item[:components].join(item[:separator] || global_separator)
      end
    end

    def quote_with(global_character)
      lambda do |item|
        character = item[:quoting] || global_character
        components = item[:components]
        switch = components[0]
        value = components[1]

        item.merge(
            components: (components.count > 1) ?
                [switch, "#{character}#{value}#{character}"] :
                components)
      end
    end
  end
end