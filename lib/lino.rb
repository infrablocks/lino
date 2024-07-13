# frozen_string_literal: true

require 'lino/version'
require 'lino/model'
require 'lino/builders'
require 'lino/executors'
require 'lino/errors'

module Lino
  class << self
    attr_writer :configuration

    def builder_for_command(command)
      Lino::Builders::CommandLine.new(command:)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset!
      @configuration = nil
    end
  end

  class Configuration
    attr_accessor :executor

    def initialize
      @executor = Executors::Childprocess.new
    end
  end

  class CommandLineBuilder
    class << self
      def for_command(command)
        Lino::Builders::CommandLine.new(command:)
      end
    end
  end
end
