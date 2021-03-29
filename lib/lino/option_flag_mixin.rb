module Lino
  module OptionFlagMixin
    def with_option(switch, value, separator: nil, quoting: nil)
      with(switches: @switches.add({
                                     components: [switch, value],
                                     separator: separator,
                                     quoting: quoting
                                   }))
    end

    def with_flag(flag)
      with(switches: @switches.add({components: [flag]}))
    end
  end
end
