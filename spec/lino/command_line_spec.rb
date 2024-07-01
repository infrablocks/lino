# frozen_string_literal: true

require 'open4'
require 'stringio'
require 'spec_helper'

describe Lino::CommandLine do
  describe '#string' do
    it 'includes the provided command' do
      expect(described_class.new('command').string)
        .to(eq('command'))
    end

    it 'includes options' do
      expect(described_class
               .new('command-with-options',
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--opt2 val2] },
                      { components: %w[--flag] },
                      { components: %w[-h] }
                    ])
               .string)
        .to(eq('command-with-options --opt1 val1 --opt2 val2 --flag -h'))
    end

    it 'uses global option separator when provided' do
      expect(described_class
               .new('command-with-separator',
                    option_separator: '=',
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--opt2 val2] }
                    ])
               .string)
        .to(eq('command-with-separator --opt1=val1 --opt2=val2'))
    end

    it 'uses per option option separator when provided' do
      expect(described_class
               .new('command-with-overridden-separator',
                    options: [
                      { components: %w[--opt1 val1], separator: '=' },
                      { components: %w[--opt2 val2], separator: ':' },
                      { components: %w[--opt3 val3] }
                    ])
               .string)
        .to(eq('command-with-overridden-separator ' \
               '--opt1=val1 --opt2:val2 --opt3 val3'))
    end

    it 'treats option specific separators as higher precedence than the ' \
       'global option separator' do
      expect(described_class
               .new('command-with-overridden-separator',
                    option_separator: '=',
                    options: [
                      { components: %w[--opt1 val1], separator: ':' },
                      { components: %w[--opt2 val2], separator: '~' },
                      { components: %w[--opt3 val3] }
                    ])
               .string)
        .to(eq('command-with-overridden-separator ' \
               '--opt1:val1 --opt2~val2 --opt3=val3'))
    end

    it 'uses global option quoting when provided' do
      expect(described_class
               .new('command-with-quoting',
                    option_quoting: '"',
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--opt2 val2] }
                    ])
               .string)
        .to(eq('command-with-quoting --opt1 "val1" --opt2 "val2"'))
    end

    it 'uses per option option quoting when provided' do
      expect(described_class
               .new('command-with-overridden-quoting',
                    options: [
                      { components: %w[--opt1 val1], quoting: '"' },
                      { components: %w[--opt2 val2], quoting: "'" },
                      { components: %w[--opt3 val3] }
                    ])
               .string)
        .to(eq('command-with-overridden-quoting ' \
               '--opt1 "val1" --opt2 \'val2\' --opt3 val3'))
    end

    it 'treats option specific quoting as higher precedence than the ' \
       'global option quoting' do
      expect(described_class
               .new('command-with-overridden-quoting',
                    option_quoting: '"',
                    options: [
                      { components: %w[--opt1 val1], quoting: "'" },
                      { components: %w[--opt2 val2], quoting: "'" },
                      { components: %w[--opt3 val3] }
                    ])
               .string)
        .to(eq('command-with-overridden-quoting ' \
               "--opt1 'val1' --opt2 'val2' --opt3 \"val3\""))
    end

    it 'includes subcommand' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new('sub')
                    ])
               .string)
        .to(eq('command-with-subcommand sub'))
    end

    it 'includes subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub',
                        options: [
                          { components: %w[--opt1 val1] },
                          { components: %w[--opt2 val2] }
                        ]
                      )
                    ])
               .string)
        .to(eq('command-with-subcommand sub --opt1 val1 --opt2 val2'))
    end

    it 'uses subcommand global option separator for subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub',
                        option_separator: '=',
                        options: [
                          { components: %w[--opt1 val1] },
                          { components: %w[--opt2 val2] }
                        ]
                      )
                    ])
               .string)
        .to(eq('command-with-subcommand sub --opt1=val1 --opt2=val2'))
    end

    it 'uses subcommand per option option separator for subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub',
                        options: [
                          { components: %w[--opt1 val1], separator: '=' },
                          { components: %w[--opt2 val2], separator: ':' },
                          { components: %w[--opt3 val3] }
                        ]
                      )
                    ])
               .string)
        .to(eq('command-with-subcommand sub ' \
               '--opt1=val1 --opt2:val2 --opt3 val3'))
    end

    it 'treats subcommand option specific separators as higher precedence ' \
       'than the subcommand global option separator' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub',
                        option_separator: '=',
                        options: [
                          { components: %w[--opt1 val1], separator: ':' },
                          { components: %w[--opt2 val2], separator: '~' },
                          { components: %w[--opt3 val3] }
                        ]
                      )
                    ])
               .string)
        .to(eq('command-with-subcommand sub ' \
               '--opt1:val1 --opt2~val2 --opt3=val3'))
    end

    it 'uses subcommand global option quoting for subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub',
                        option_quoting: '"',
                        options: [
                          { components: %w[--opt1 val1] },
                          { components: %w[--opt2 val2] }
                        ]
                      )
                    ])
               .string)
        .to(eq('command-with-subcommand sub --opt1 "val1" --opt2 "val2"'))
    end

    it 'uses subcommand per option option quoting for subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub',
                        options: [
                          { components: %w[--opt1 val1], quoting: '"' },
                          { components: %w[--opt2 val2], quoting: "'" },
                          { components: %w[--opt3 val3] }
                        ]
                      )
                    ])
               .string)
        .to(eq('command-with-subcommand sub ' \
               '--opt1 "val1" --opt2 \'val2\' --opt3 val3'))
    end

    it 'treats subcommand option specific quoting as higher precedence ' \
       'than the subcommand global option quoting' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub',
                        option_quoting: '"',
                        options: [
                          { components: %w[--opt1 val1], quoting: "'" },
                          { components: %w[--opt2 val2], quoting: "'" },
                          { components: %w[--opt3 val3] }
                        ]
                      )
                    ])
               .string)
        .to(eq('command-with-subcommand sub ' \
               "--opt1 'val1' --opt2 'val2' --opt3 \"val3\""))
    end

    it 'includes arguments' do
      expect(described_class
               .new('command-with-arguments',
                    arguments: [
                      { components: %w[arg1] },
                      { components: %w[arg2] },
                      { components: %w[arg3] }
                    ])
               .string)
        .to(eq('command-with-arguments arg1 arg2 arg3'))
    end

    it 'includes arguments after options' do
      expect(described_class
               .new('command-with-arguments',
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--flag] }
                    ],
                    arguments: [
                      { components: %w[arg1] },
                      { components: %w[arg2] }
                    ])
               .string)
        .to(eq('command-with-arguments --opt1 val1 --flag arg1 arg2'))
    end

    it 'includes arguments after subcommands' do
      expect(described_class
               .new('command-with-arguments',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub1',
                        options: [{ components: %w[--opt1 val1] }]
                      ),
                      Lino::Subcommand.new(
                        'sub2'
                      )
                    ],
                    arguments: [
                      { components: %w[arg1] },
                      { components: %w[arg2] }
                    ])
               .string)
        .to(eq('command-with-arguments sub1 --opt1 val1 sub2 arg1 arg2'))
    end

    it 'includes environment variables before command' do
      expect(described_class
               .new('command-with-environment-variables',
                    environment_variables: [
                      %w[ENV_VAR1 VAL1],
                      %w[ENV_VAR2 VAL2]
                    ])
               .string)
        .to(eq('ENV_VAR1="VAL1" ENV_VAR2="VAL2" ' \
               'command-with-environment-variables'))
    end

    it 'includes command options before subcommands by default' do
      expect(described_class
               .new('command-with-subcommand',
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--flag] }
                    ],
                    subcommands: [
                      Lino::Subcommand.new('sub')
                    ])
               .string)
        .to(eq('command-with-subcommand --opt1 val1 --flag sub'))
    end

    it 'includes command options before subcommands when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    option_placement: :after_command,
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--flag] }
                    ],
                    subcommands: [
                      Lino::Subcommand.new('sub')
                    ])
               .string)
        .to(eq('command-with-subcommand --opt1 val1 --flag sub'))
    end

    it 'includes command options after subcommands when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    option_placement: :after_subcommands,
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--flag] }
                    ],
                    arguments: [
                      { components: %w[arg1] },
                      { components: %w[arg2] }
                    ],
                    subcommands: [
                      Lino::Subcommand.new('sub')
                    ])
               .string)
        .to(eq('command-with-subcommand sub ' \
               '--opt1 val1 --flag arg1 arg2'))
    end

    it 'includes command options after arguments when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    option_placement: :after_arguments,
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--flag] }
                    ],
                    arguments: [
                      { components: %w[arg1] },
                      { components: %w[arg2] }
                    ],
                    subcommands: [
                      Lino::Subcommand.new('sub')
                    ])
               .string)
        .to(eq('command-with-subcommand sub arg1 arg2 ' \
               '--opt1 val1 --flag'))
    end

    it 'uses per option option placement when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    options: [
                      {
                        components: %w[--opt1 val1],
                        placement: :after_command
                      },
                      {
                        components: %w[--flag1],
                        placement: :after_arguments
                      },
                      {
                        components: %w[--flag2],
                        placement: :after_subcommands
                      }
                    ],
                    arguments: [
                      { components: %w[arg1] },
                      { components: %w[arg2] }
                    ],
                    subcommands: [
                      Lino::Subcommand.new('sub')
                    ])
               .string)
        .to(eq('command-with-subcommand --opt1 val1 sub --flag2 ' \
               'arg1 arg2 --flag1'))
    end

    it 'treats option specific placement as higher precedence ' \
       'than the global option placement' do
      expect(described_class
               .new('command-with-subcommand',
                    option_placement: :after_arguments,
                    options: [
                      {
                        components: %w[--opt1 val1],
                        placement: :after_command
                      },
                      {
                        components: %w[--flag1],
                        placement: :after_subcommands
                      },
                      {
                        components: %w[--flag2]
                      }
                    ],
                    arguments: [
                      { components: %w[arg1] },
                      { components: %w[arg2] }
                    ],
                    subcommands: [
                      Lino::Subcommand.new('sub')
                    ])
               .string)
        .to(eq('command-with-subcommand --opt1 val1 sub --flag1 ' \
               'arg1 arg2 --flag2'))
    end
  end

  describe '#array' do
    it 'includes the provided command' do
      expect(described_class.new('command').array)
        .to(eq(%w[command]))
    end

    it 'includes options' do
      expect(described_class
               .new('command-with-options',
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--opt2 val2] },
                      { components: %w[--flag] },
                      { components: %w[-h] }
                    ])
               .array)
        .to(eq(%w[command-with-options --opt1 val1 --opt2 val2 --flag -h]))
    end

    it 'uses global option separator when provided' do
      expect(described_class
               .new('command-with-separator',
                    option_separator: '=',
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--opt2 val2] }
                    ])
               .array)
        .to(eq(%w[command-with-separator --opt1=val1 --opt2=val2]))
    end

    it 'uses per option option separator when provided' do
      expect(described_class
               .new('command-with-overridden-separator',
                    options: [
                      { components: %w[--opt1 val1], separator: '=' },
                      { components: %w[--opt2 val2], separator: ':' },
                      { components: %w[--opt3 val3] }
                    ])
               .array)
        .to(eq(%w[command-with-overridden-separator
                  --opt1=val1 --opt2:val2 --opt3 val3]))
    end

    it 'treats option specific separators as higher precedence than the ' \
       'global option separator' do
      expect(described_class
               .new('command-with-overridden-separator',
                    option_separator: '=',
                    options: [
                      { components: %w[--opt1 val1], separator: ':' },
                      { components: %w[--opt2 val2], separator: '~' },
                      { components: %w[--opt3 val3] }
                    ])
               .array)
        .to(eq(%w[command-with-overridden-separator
                  --opt1:val1 --opt2~val2 --opt3=val3]))
    end

    it 'ignores global option quoting when provided' do
      expect(described_class
               .new('command-with-quoting',
                    option_quoting: '"',
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--opt2 val2] }
                    ])
               .array)
        .to(eq(%w[command-with-quoting --opt1 val1 --opt2 val2]))
    end

    it 'ignores per option option quoting when provided' do
      expect(described_class
               .new('command-with-overridden-quoting',
                    options: [
                      { components: %w[--opt1 val1], quoting: '"' },
                      { components: %w[--opt2 val2], quoting: "'" },
                      { components: %w[--opt3 val3] }
                    ])
               .array)
        .to(eq(%w[command-with-overridden-quoting
                  --opt1 val1 --opt2 val2 --opt3 val3]))
    end

    it 'ignores option specific quoting and global option quoting ' \
       'when both provided' do
      expect(described_class
               .new('command-with-overridden-quoting',
                    option_quoting: '"',
                    options: [
                      { components: %w[--opt1 val1], quoting: "'" },
                      { components: %w[--opt2 val2], quoting: "'" },
                      { components: %w[--opt3 val3] }
                    ])
               .array)
        .to(eq(%w[command-with-overridden-quoting
                  --opt1 val1 --opt2 val2 --opt3 val3]))
    end

    it 'includes subcommand' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new('sub')
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub]))
    end

    it 'includes subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub',
                        options: [
                          { components: %w[--opt1 val1] },
                          { components: %w[--opt2 val2] }
                        ]
                      )
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub --opt1 val1 --opt2 val2]))
    end

    it 'uses subcommand global option separator for subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub',
                        option_separator: '=',
                        options: [
                          { components: %w[--opt1 val1] },
                          { components: %w[--opt2 val2] }
                        ]
                      )
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub --opt1=val1 --opt2=val2]))
    end

    it 'uses subcommand per option option separator for subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub',
                        options: [
                          { components: %w[--opt1 val1], separator: '=' },
                          { components: %w[--opt2 val2], separator: ':' },
                          { components: %w[--opt3 val3] }
                        ]
                      )
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub
                  --opt1=val1 --opt2:val2 --opt3 val3]))
    end

    it 'treats subcommand option specific separators as higher precedence ' \
       'than the subcommand global option separator' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub',
                        option_separator: '=',
                        options: [
                          { components: %w[--opt1 val1], separator: ':' },
                          { components: %w[--opt2 val2], separator: '~' },
                          { components: %w[--opt3 val3] }
                        ]
                      )
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub
                  --opt1:val1 --opt2~val2 --opt3=val3]))
    end

    it 'ignores subcommand global option quoting for subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub',
                        option_quoting: '"',
                        options: [
                          { components: %w[--opt1 val1] },
                          { components: %w[--opt2 val2] }
                        ]
                      )
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub --opt1 val1 --opt2 val2]))
    end

    it 'ignores subcommand per option option quoting for subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub',
                        options: [
                          { components: %w[--opt1 val1], quoting: '"' },
                          { components: %w[--opt2 val2], quoting: "'" },
                          { components: %w[--opt3 val3] }
                        ]
                      )
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub
                  --opt1 val1 --opt2 val2 --opt3 val3]))
    end

    it 'ignores subcommand option specific quoting and subcommand global ' \
       'option quoting when both provided' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub',
                        option_quoting: '"',
                        options: [
                          { components: %w[--opt1 val1], quoting: "'" },
                          { components: %w[--opt2 val2], quoting: "'" },
                          { components: %w[--opt3 val3] }
                        ]
                      )
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub
                  --opt1 val1 --opt2 val2 --opt3 val3]))
    end

    it 'includes arguments' do
      expect(described_class
               .new('command-with-arguments',
                    arguments: [
                      { components: %w[arg1] },
                      { components: %w[arg2] },
                      { components: %w[arg3] }
                    ])
               .array)
        .to(eq(%w[command-with-arguments arg1 arg2 arg3]))
    end

    it 'includes arguments after options' do
      expect(described_class
               .new('command-with-arguments',
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--flag] }
                    ],
                    arguments: [
                      { components: %w[arg1] },
                      { components: %w[arg2] }
                    ])
               .array)
        .to(eq(%w[command-with-arguments --opt1 val1 --flag arg1 arg2]))
    end

    it 'includes arguments after subcommands' do
      expect(described_class
               .new('command-with-arguments',
                    subcommands: [
                      Lino::Subcommand.new(
                        'sub1',
                        options: [{ components: %w[--opt1 val1] }]
                      ),
                      Lino::Subcommand.new(
                        'sub2'
                      )
                    ],
                    arguments: [
                      { components: %w[arg1] },
                      { components: %w[arg2] }
                    ])
               .array)
        .to(eq(%w[command-with-arguments sub1 --opt1 val1 sub2 arg1 arg2]))
    end

    it 'ignores environment variables' do
      expect(described_class
               .new('command-with-environment-variables',
                    environment_variables: [
                      %w[ENV_VAR1 VAL1],
                      %w[ENV_VAR2 VAL2]
                    ])
               .array)
        .to(eq(%w[command-with-environment-variables]))
    end

    it 'includes command options before subcommands by default' do
      expect(described_class
               .new('command-with-subcommand',
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--flag] }
                    ],
                    subcommands: [
                      Lino::Subcommand.new('sub')
                    ])
               .array)
        .to(eq(%w[command-with-subcommand --opt1 val1 --flag sub]))
    end

    it 'includes command options before subcommands when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    option_placement: :after_command,
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--flag] }
                    ],
                    subcommands: [
                      Lino::Subcommand.new('sub')
                    ])
               .array)
        .to(eq(%w[command-with-subcommand --opt1 val1 --flag sub]))
    end

    it 'includes command options after subcommands when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    option_placement: :after_subcommands,
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--flag] }
                    ],
                    arguments: [
                      { components: %w[arg1] },
                      { components: %w[arg2] }
                    ],
                    subcommands: [
                      Lino::Subcommand.new('sub')
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub
                  --opt1 val1 --flag arg1 arg2]))
    end

    it 'includes command options after arguments when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    option_placement: :after_arguments,
                    options: [
                      { components: %w[--opt1 val1] },
                      { components: %w[--flag] }
                    ],
                    arguments: [
                      { components: %w[arg1] },
                      { components: %w[arg2] }
                    ],
                    subcommands: [
                      Lino::Subcommand.new('sub')
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub arg1 arg2
                  --opt1 val1 --flag]))
    end

    it 'uses per option option placement when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    options: [
                      {
                        components: %w[--opt1 val1],
                        placement: :after_command
                      },
                      {
                        components: %w[--flag1],
                        placement: :after_arguments
                      },
                      {
                        components: %w[--flag2],
                        placement: :after_subcommands
                      }
                    ],
                    arguments: [
                      { components: %w[arg1] },
                      { components: %w[arg2] }
                    ],
                    subcommands: [
                      Lino::Subcommand.new('sub')
                    ])
               .array)
        .to(eq(%w[command-with-subcommand --opt1 val1 sub --flag2
                  arg1 arg2 --flag1]))
    end

    it 'treats option specific placement as higher precedence ' \
       'than the global option placement' do
      expect(described_class
               .new('command-with-subcommand',
                    option_placement: :after_arguments,
                    options: [
                      {
                        components: %w[--opt1 val1],
                        placement: :after_command
                      },
                      {
                        components: %w[--flag1],
                        placement: :after_subcommands
                      },
                      {
                        components: %w[--flag2]
                      }
                    ],
                    arguments: [
                      { components: %w[arg1] },
                      { components: %w[arg2] }
                    ],
                    subcommands: [
                      Lino::Subcommand.new('sub')
                    ])
               .array)
        .to(eq(%w[command-with-subcommand --opt1 val1 sub --flag1
                  arg1 arg2 --flag2]))
    end
  end

  describe '#execute' do
    it 'executes the command line with an empty stdin and default ' \
       'stdout and stderr when not provided' do
      command_line = described_class.new(
        'ls',
        options: [{ components: ['-la'] }]
      )

      allow(Open4).to(receive(:spawn))

      command_line.execute

      expect(Open4).to(
        have_received(:spawn).with(
          {},
          'ls', '-la',
          stdin: '',
          stdout: $stdout,
          stderr: $stderr
        )
      )
    end

    it 'uses the supplied stdin, stdout and stderr when provided' do
      command_line = described_class.new(
        'ls',
        options: [{ components: ['-la'] }]
      )

      stdin = 'hello'
      stdout = StringIO.new
      stderr = StringIO.new

      allow(Open4).to(receive(:spawn))

      command_line.execute(
        stdin: stdin,
        stdout: stdout,
        stderr: stderr
      )

      expect(Open4).to(
        have_received(:spawn).with(
          {},
          'ls', '-la',
          stdin: stdin,
          stdout: stdout,
          stderr: stderr
        )
      )
    end
  end
end
