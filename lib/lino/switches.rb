module Lino
  module Switches
    def with_option(switch, value, separator: nil, quoting: nil)
      with(switches: add_option(switch, value, separator, quoting))
    end

    def with_repeated_option(switch, values, separator: nil, quoting: nil)
      values.each do |value|
        add_option(switch, value, separator, quoting)
      end
      with({})
    end

    def with_flag(flag)
      with(switches: @switches.add({ components: [flag] }))
    end

    private

    def add_option(switch, value, separator, quoting)
      return @switches if missing?(value)

      @switches = @switches.add(
        {
          components: [switch, value],
          separator: separator,
          quoting: quoting
        }
      )
    end
  end
end
