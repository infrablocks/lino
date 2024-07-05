# frozen_string_literal: true

require 'hamster'

require_relative 'subcommand'
require_relative 'mixins/options'
require_relative 'mixins/appliables'

module Lino
  class SubcommandBuilder
    include Mixins::Options
    include Mixins::Appliables

    class << self
      def for_subcommand(subcommand)
        SubcommandBuilder.new(subcommand: subcommand)
      end
    end

    def initialize(state)
      @subcommand = state[:subcommand]
      @options = Hamster::Vector.new(state[:options] || [])
    end

    def build
      Subcommand.new(
        @subcommand,
        options: build_options
      )
    end

    private

    def with(replacements)
      SubcommandBuilder.new(state.merge(replacements))
    end

    def state
      {
        subcommand: @subcommand,
        options: @options
      }
    end
  end
end
