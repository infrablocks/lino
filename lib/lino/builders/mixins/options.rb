# frozen_string_literal: true

require_relative '../../model'
require_relative 'validation'
require_relative 'defaulting'

module Lino
  module Builders
    module Mixins
      module Options
        include Validation
        include Defaulting

        def initialize(state)
          @options = Hamster::Vector.new(state[:options] || [])
          super
        end

        def with_option(
          option,
          value,
          separator: nil,
          quoting: nil,
          placement: nil
        )
          return self if value.nil?

          with(options: @options.add(
            {
              type: :option,
              components: [option, value],
              separator:,
              quoting:,
              placement:
            }
          ))
        end

        def with_options(options)
          return self if nil_or_empty?(options)

          options.entries.inject(self) do |s, entry|
            s.with_option(
              or_nth(entry, :option, 0),
              or_nth(entry, :value, 1),
              separator: or_nil(entry, :separator),
              quoting: or_nil(entry, :quoting),
              placement: or_nil(entry, :placement)
            )
          end
        end

        def with_repeated_option(
          option,
          values,
          separator: nil,
          quoting: nil,
          placement: nil
        )
          values.inject(self) do |s, value|
            s.with_option(
              option,
              value,
              separator:,
              quoting:,
              placement:
            )
          end
        end

        def with_flag(flag)
          return self if flag.nil?

          with(options: @options.add(
            {
              type: :flag,
              components: [flag]
            }
          ))
        end

        def with_flags(flags)
          return self if nil_or_empty?(flags)

          flags.inject(self) { |s, flag| s.with_flag(flag) }
        end

        private

        def state
          super.merge(options: @options)
        end

        def build_options(option_separator, option_quoting, option_placement)
          @options.map do |data|
            if data[:type] == :option
              build_option(
                data, option_separator, option_quoting, option_placement
              )
            else
              build_flag(data, option_placement)
            end
          end
        end

        def build_option(
          option_data, option_separator, option_quoting, option_placement
        )
          Model::Option.new(
            *option_data[:components],
            separator: option_data[:separator] || option_separator,
            quoting: option_data[:quoting] || option_quoting,
            placement: option_data[:placement] || option_placement
          )
        end

        def build_flag(flag_data, option_placement)
          Model::Flag.new(
            *flag_data[:components],
            placement: flag_data[:placement] || option_placement
          )
        end
      end
    end
  end
end
