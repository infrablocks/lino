# frozen_string_literal: true

require_relative 'construction'
require_relative 'validation'

module Lino
  class Subcommand
    include Construction
    include Validation

    attr_reader :subcommand,
                :options,
                :option_separator,
                :option_quoting

    def initialize(subcommand, opts)
      @subcommand = subcommand
      @options = Hamster::Vector.new(opts[:options])
      @option_separator = opts[:option_separator]
      @option_quoting = opts[:option_quoting]
    end

    def to_s
      components = [
        @subcommand,
        map_and_join(
          @options,
          &(quote_with(@option_quoting) >> join_with(@option_separator))
        )
      ]
      components.reject(&:empty?).join(' ')
    end

    def to_a
      [
        @subcommand,
        @options.map do |option|
          components = option[:components]
          separator = option[:separator] || @option_separator
          separator == ' ' ? components : [components.join(separator)]
        end
      ].flatten
    end

    private

    def with_defaults(opts)
      opts.merge({ options: opts.fetch(:options, []) })
    end
  end
end
