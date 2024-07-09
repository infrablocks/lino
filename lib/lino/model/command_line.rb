# frozen_string_literal: true

module Lino
  module Model
    class CommandLine
      COMPONENTS = [
        %i[environment_variables],
        %i[command],
        %i[options after_command],
        %i[subcommands],
        %i[options after_subcommands],
        %i[arguments],
        %i[options after_arguments]
      ].freeze

      attr_reader :command,
                  :subcommands,
                  :options,
                  :arguments,
                  :environment_variables,
                  :executor,
                  :working_directory

      def initialize(command, opts = {})
        opts = with_defaults(opts)
        @command = command
        @subcommands = Hamster::Vector.new(opts[:subcommands])
        @options = Hamster::Vector.new(opts[:options])
        @arguments = Hamster::Vector.new(opts[:arguments])
        @environment_variables =
          Hamster::Vector.new(opts[:environment_variables])
        @executor = opts[:executor]
        @working_directory = opts[:working_directory]
      end

      def execute(opts = {})
        @executor.execute(self, opts)
      end

      def env
        @environment_variables.to_h(&:array)
      end

      def array
        format_components(:array, COMPONENTS.drop(1)).flatten
      end

      alias to_a array

      def string
        format_components(:string, COMPONENTS).join(' ')
      end

      alias to_s string

      def ==(other)
        self.class == other.class && state == other.state
      end

      alias eql? ==

      def hash
        [self.class, state].hash
      end

      protected

      def state
        [
          @command,
          @subcommands,
          @options,
          @arguments,
          @environment_variables,
          @executor,
          @working_directory
        ]
      end

      private

      def with_defaults(opts)
        {
          subcommands: opts.fetch(:subcommands, []),
          options: opts.fetch(:options, []),
          arguments: opts.fetch(:arguments, []),
          environment_variables: opts.fetch(:environment_variables, []),
          executor: opts.fetch(:executor, Lino.configuration.executor),
          working_directory: opts.fetch(:working_directory, nil)
        }
      end

      def format_components(format, paths)
        paths
          .collect { |p| components_at_path(formatted_components(format), p) }
          .compact
          .reject(&:empty?)
      end

      def formatted_components(format)
        {
          environment_variables: @environment_variables.map(&format),
          command: @command.to_s,
          options: @options
            .group_by(&:placement)
            .map { |p, o| [p, o.map(&format)] },
          subcommands: @subcommands.map(&format),
          arguments: @arguments.map(&format)
        }
      end

      def components_at_path(components, path)
        path.inject(components) { |c, p| c && c[p] }
      end
    end
  end
end
