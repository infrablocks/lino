# frozen_string_literal: true

require 'lino/version'
require 'lino/model'
require 'lino/builders'

module Lino
  class CommandLineBuilder
    class << self
      def for_command(command)
        Lino::Builders::CommandLine.new(command: command)
      end
    end
  end
end
