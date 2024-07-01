# frozen_string_literal: true

module Lino
  module Construction
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
        item.merge(
          components: resolve_components(item, global_character)
        )
      end
    end

    private

    def resolve_components(item, global_character)
      components = item[:components]
      switch = components[0]

      if components.count > 1
        character = item[:quoting] || global_character
        value = components[1]

        [switch, "#{character}#{value}#{character}"]
      else
        components
      end
    end
  end
end
