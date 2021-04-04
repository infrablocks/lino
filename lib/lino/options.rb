# frozen_string_literal: true

module Lino
  module Options
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

    def with_repeated_option(option, values, separator: nil, quoting: nil)
      values.inject(self) do |s, value|
        s.with_option(option, value, separator: separator, quoting: quoting)
      end
    end

    def with_flag(flag)
      with(options: @options.add({ components: [flag] }))
    end
  end
end
