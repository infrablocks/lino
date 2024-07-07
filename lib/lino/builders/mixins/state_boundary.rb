# frozen_string_literal: true

require_relative 'validation'
require_relative '../../model'

module Lino
  module Builders
    module Mixins
      module StateBoundary
        def initialize(_state)
          super()
        end
      end
    end
  end
end
