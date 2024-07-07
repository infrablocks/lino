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
          return self if nil?(value)

          with(options: @options.add(
            {
              type: :option,
              components: [option, value],
              separator: separator,
              quoting: quoting,
              placement: placement
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
              separator: separator,
              quoting: quoting,
              placement: placement
            )
          end
        end

        def with_flag(flag)
          return self if nil?(flag)

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

        # rubocop:disable Metrics/MethodLength
        def build_options
          @options.map do |o|
            if o[:type] == :option
              Model::Option.new(
                *o[:components],
                separator: o[:separator] || @option_separator,
                quoting: o[:quoting] || @option_quoting,
                placement: o[:placement] || @option_placement
              )
            else
              Model::Flag.new(
                *o[:components],
                placement: o[:placement] || @option_placement
              )
            end
          end
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
