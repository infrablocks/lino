# frozen_string_literal: true

require_relative 'validation'
require_relative '../../model'

module Lino
  module Builders
    module Mixins
      module EnvironmentVariables
        include Validation

        def with_environment_variable(environment_variable, value)
          with(
            environment_variables:
              @environment_variables.add(
                Model::EnvironmentVariable.new(environment_variable, value)
              )
          )
        end

        def with_environment_variables(environment_variables)
          return self if nil_or_empty?(environment_variables)

          environment_variables.entries.inject(self) do |s, var|
            s.with_environment_variable(
              var.include?(:name) ? var[:name] : var[0],
              var.include?(:value) ? var[:value] : var[1]
            )
          end
        end
      end
    end
  end
end
