# frozen_string_literal: true

require 'hamster'

require_relative '../model'
require_relative 'mixins/options'
require_relative 'mixins/appliables'

module Lino
  module Builders
    class Subcommand
      include Mixins::Options
      include Mixins::Appliables

      class << self
        def for_subcommand(subcommand)
          Builders::Subcommand.new(subcommand:)
        end
      end

      def initialize(state)
        @subcommand = state[:subcommand]
        @options = Hamster::Vector.new(state[:options] || [])
      end

      def build(option_separator, option_quoting, option_placement)
        Model::Subcommand.new(
          @subcommand,
          options: build_options(
            option_separator,
            option_quoting,
            option_placement
          )
        )
      end

      private

      def with(replacements)
        Builders::Subcommand.new(state.merge(replacements))
      end

      def state
        {
          subcommand: @subcommand,
          options: @options
        }
      end
    end
  end
end
