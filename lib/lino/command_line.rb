# frozen_string_literal: true

require 'open4'

require_relative 'construction'
require_relative 'validation'

module Lino
  # rubocop:disable Metrics/ClassLength
  class CommandLine
    include Construction
    include Validation

    attr_reader :command,
                :subcommands,
                :options,
                :arguments,
                :environment_variables,
                :option_separator,
                :option_quoting,
                :option_placement

    def initialize(command, opts = {})
      opts = with_defaults(opts)
      @command = command
      @subcommands = Hamster::Vector.new(opts[:subcommands])
      @options = Hamster::Vector.new(opts[:options])
      @arguments = Hamster::Vector.new(opts[:arguments])
      @environment_variables = Hamster::Vector.new(opts[:environment_variables])
      @option_separator = opts[:option_separator]
      @option_quoting = opts[:option_quoting]
      @option_placement = opts[:option_placement]
    end

    def execute(
      stdin: '',
      stdout: $stdout,
      stderr: $stderr
    )
      Open4.spawn(
        env,
        *to_a,
        stdin: stdin,
        stdout: stdout,
        stderr: stderr
      )
    end

    def array
      array_component_paths
        .collect do |path|
        components_at_path(array_formatted_components, path)
      end
        .reject(&:empty?)
        .flatten
    end
    alias to_a array

    def string
      string_component_paths
        .collect do |path|
        components_at_path(string_formatted_components, path)
      end
        .reject(&:empty?)
        .join(' ')
    end
    alias to_s string

    private

    def with_defaults(opts)
      {
        subcommands: opts.fetch(:subcommands, []),
        options: opts.fetch(:options, []),
        arguments: opts.fetch(:arguments, []),
        environment_variables: opts.fetch(:environment_variables, []),
        option_separator: opts.fetch(:option_separator, ' '),
        option_quoting: opts.fetch(:option_quoting, nil),
        option_placement: opts.fetch(:option_placement, :after_command)
      }
    end

    def env
      @environment_variables.to_h
    end

    def array_component_paths
      [
        %i[command],
        %i[options after_command],
        %i[subcommands],
        %i[options after_subcommands],
        %i[arguments],
        %i[options after_arguments]
      ]
    end

    def string_component_paths
      [%i[environment_variables]].concat(array_component_paths)
    end

    def array_formatted_components
      @array_formatted_components ||= {
        command: @command,
        options: array_formatted_options,
        subcommands: array_formatted_subcommands,
        arguments: array_formatted_arguments
      }
    end

    def string_formatted_components
      @string_formatted_components ||= {
        environment_variables: string_formatted_environment_variables,
        command: @command,
        options: string_formatted_options,
        subcommands: string_formatted_subcommands,
        arguments: string_formatted_arguments
      }
    end

    def string_formatted_environment_variables
      map_and_join(@environment_variables) do |var|
        "#{var[0]}=\"#{var[1].to_s.gsub('"', '\\"')}\""
      end
    end

    def array_formatted_options_with_placement(placement)
      options_with_placement(placement).map do |option|
        separator = option[:separator] || @option_separator
        components = option[:components]
        separator == ' ' ? components : [components.join(separator)]
      end
    end

    def string_formatted_options_with_placement(placement)
      map_and_join(
        options_with_placement(placement),
        &(quote_with(@option_quoting) >> join_with(@option_separator))
      )
    end

    def array_formatted_options
      %i[
        after_command
        after_subcommands
        after_arguments
      ].inject({}) do |options, placement|
        options
          .merge({ placement =>
                     array_formatted_options_with_placement(placement) })
      end
    end

    def string_formatted_options
      %i[
        after_command
        after_subcommands
        after_arguments
      ].inject({}) do |options, placement|
        options
          .merge({ placement =>
                     string_formatted_options_with_placement(placement) })
      end
    end

    def array_formatted_subcommands
      @subcommands.map(&:to_a)
    end

    def string_formatted_subcommands
      map_and_join(@subcommands, &:to_s)
    end

    def array_formatted_arguments
      @arguments.map { |a| a[:components] }
    end

    def string_formatted_arguments
      map_and_join(
        @arguments,
        &join_with(' ')
      )
    end

    def components_at_path(components, path)
      path.inject(components) { |c, p| c && c[p] }
    end

    def options_with_placement(placement)
      @options.select { |o| o[:placement] == placement } +
        if @option_placement == placement
          @options.select { |o| o[:placement].nil? }
        end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
