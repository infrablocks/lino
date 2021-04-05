# frozen_string_literal: true

require_relative 'utilities'

module Lino
  module Options
    include Lino::Utilities

    def with_option(option, value, separator: nil, quoting: nil)
      return self if missing?(value)

      with(options: @options.add(
        {
          components: [option, value],
          separator: separator,
          quoting: quoting
        }
      ))
    end

    def with_options(options)
      return self if missing?(options)

      options.entries.inject(self) do |s, entry|
        s.with_option(
          entry.include?(:option) ? entry[:option] : entry[0],
          entry.include?(:value) ? entry[:value] : entry[1],
          separator: (entry.include?(:separator) ? entry[:separator] : nil),
          quoting: (entry.include?(:quoting) ? entry[:quoting] : nil)
        )
      end
    end

    def with_repeated_option(option, values, separator: nil, quoting: nil)
      values.inject(self) do |s, value|
        s.with_option(option, value, separator: separator, quoting: quoting)
      end
    end

    def with_flag(flag)
      return self if missing?(flag)

      with(options: @options.add({ components: [flag] }))
    end

    def with_flags(flags)
      return self if missing?(flags)

      flags.inject(self) { |s, flag| s.with_flag(flag) }
    end
  end
end
