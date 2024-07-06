# frozen_string_literal: true

require 'open4'
require 'stringio'
require 'spec_helper'

describe Lino::Model::CommandLine do
  describe '#string' do
    it 'includes the provided command' do
      expect(described_class.new('command').string)
        .to(eq('command'))
    end

    it 'includes options' do
      expect(described_class
               .new('command-with-options',
                    options: [
                      Lino::Model::Option.new('--opt1', 'val1'),
                      Lino::Model::Option.new('--opt2', 'val2'),
                      Lino::Model::Flag.new('--flag'),
                      Lino::Model::Flag.new('-h')
                    ])
               .string)
        .to(eq('command-with-options --opt1 val1 --opt2 val2 --flag -h'))
    end

    it 'uses option separator when provided' do
      expect(described_class
               .new('command-with-overridden-separator',
                    options: [
                      Lino::Model::Option.new(
                        '--opt1', 'val1', separator: '='
                      ),
                      Lino::Model::Option.new(
                        '--opt2', 'val2', separator: ':'
                      ),
                      Lino::Model::Option.new('--opt3', 'val3')
                    ])
               .string)
        .to(eq('command-with-overridden-separator ' \
               '--opt1=val1 --opt2:val2 --opt3 val3'))
    end

    it 'uses option quoting when provided' do
      expect(described_class
               .new('command-with-overridden-quoting',
                    options: [
                      Lino::Model::Option.new(
                        '--opt1', 'val1', quoting: '"'
                      ),
                      Lino::Model::Option.new(
                        '--opt2', 'val2', quoting: "'"
                      ),
                      Lino::Model::Option.new('--opt3', 'val3')
                    ])
               .string)
        .to(eq('command-with-overridden-quoting ' \
               '--opt1 "val1" --opt2 \'val2\' --opt3 val3'))
    end

    it 'includes subcommand' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Model::Subcommand.new('sub')
                    ])
               .string)
        .to(eq('command-with-subcommand sub'))
    end

    it 'includes subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Model::Subcommand.new(
                        'sub',
                        options: [
                          Lino::Model::Option.new('--opt1', 'val1'),
                          Lino::Model::Option.new('--opt2', 'val2')
                        ]
                      )
                    ])
               .string)
        .to(eq('command-with-subcommand sub --opt1 val1 --opt2 val2'))
    end

    it 'uses subcommand option separator for subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Model::Subcommand.new(
                        'sub',
                        options: [
                          Lino::Model::Option.new(
                            '--opt1', 'val1', separator: '='
                          ),
                          Lino::Model::Option.new(
                            '--opt2', 'val2', separator: ':'
                          ),
                          Lino::Model::Option.new('--opt3', 'val3')
                        ]
                      )
                    ])
               .string)
        .to(eq('command-with-subcommand sub ' \
               '--opt1=val1 --opt2:val2 --opt3 val3'))
    end

    it 'uses subcommand option quoting for subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Model::Subcommand.new(
                        'sub',
                        options: [
                          Lino::Model::Option.new(
                            '--opt1', 'val1', quoting: '"'
                          ),
                          Lino::Model::Option.new(
                            '--opt2', 'val2', quoting: "'"
                          ),
                          Lino::Model::Option.new('--opt3', 'val3')
                        ]
                      )
                    ])
               .string)
        .to(eq('command-with-subcommand sub ' \
               '--opt1 "val1" --opt2 \'val2\' --opt3 val3'))
    end

    it 'includes arguments' do
      expect(described_class
               .new('command-with-arguments',
                    arguments: [
                      Lino::Model::Argument.new('arg1'),
                      Lino::Model::Argument.new('arg2'),
                      Lino::Model::Argument.new('arg3')
                    ])
               .string)
        .to(eq('command-with-arguments arg1 arg2 arg3'))
    end

    it 'includes arguments after options' do
      expect(described_class
               .new('command-with-arguments',
                    options: [
                      Lino::Model::Option.new('--opt1', 'val1'),
                      Lino::Model::Flag.new('--flag')
                    ],
                    arguments: [
                      Lino::Model::Argument.new('arg1'),
                      Lino::Model::Argument.new('arg2')
                    ])
               .string)
        .to(eq('command-with-arguments --opt1 val1 --flag arg1 arg2'))
    end

    it 'includes arguments after subcommands' do
      expect(described_class
               .new('command-with-arguments',
                    subcommands: [
                      Lino::Model::Subcommand.new(
                        'sub1',
                        options: [
                          Lino::Model::Option.new('--opt1', 'val1')
                        ]
                      ),
                      Lino::Model::Subcommand.new(
                        'sub2'
                      )
                    ],
                    arguments: [
                      Lino::Model::Argument.new('arg1'),
                      Lino::Model::Argument.new('arg2')
                    ])
               .string)
        .to(eq('command-with-arguments sub1 --opt1 val1 sub2 arg1 arg2'))
    end

    it 'includes environment variables before command' do
      expect(described_class
               .new('command-with-environment-variables',
                    environment_variables: [
                      Lino::Model::EnvironmentVariable.new('ENV_VAR1', 'VAL1'),
                      Lino::Model::EnvironmentVariable.new('ENV_VAR2', 'VAL2')
                    ])
               .string)
        .to(eq('ENV_VAR1="VAL1" ENV_VAR2="VAL2" ' \
               'command-with-environment-variables'))
    end

    it 'includes command options before subcommands by default' do
      expect(described_class
               .new('command-with-subcommand',
                    options: [
                      Lino::Model::Option.new('--opt1', 'val1'),
                      Lino::Model::Flag.new('--flag')
                    ],
                    subcommands: [
                      Lino::Model::Subcommand.new('sub')
                    ])
               .string)
        .to(eq('command-with-subcommand --opt1 val1 --flag sub'))
    end

    it 'includes command options before subcommands when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    option_placement: :after_command,
                    options: [
                      Lino::Model::Option.new('--opt1', 'val1'),
                      Lino::Model::Flag.new('--flag')
                    ],
                    subcommands: [
                      Lino::Model::Subcommand.new('sub')
                    ])
               .string)
        .to(eq('command-with-subcommand --opt1 val1 --flag sub'))
    end

    it 'includes command options after subcommands when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    options: [
                      Lino::Model::Option.new(
                        '--opt1', 'val1', placement: :after_subcommands
                      ),
                      Lino::Model::Flag.new(
                        '--flag', placement: :after_subcommands
                      )
                    ],
                    arguments: [
                      Lino::Model::Argument.new('arg1'),
                      Lino::Model::Argument.new('arg2')
                    ],
                    subcommands: [
                      Lino::Model::Subcommand.new('sub')
                    ])
               .string)
        .to(eq('command-with-subcommand sub ' \
               '--opt1 val1 --flag arg1 arg2'))
    end

    it 'includes command options after arguments when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    options: [
                      Lino::Model::Option.new(
                        '--opt1', 'val1', placement: :after_arguments
                      ),
                      Lino::Model::Flag.new(
                        '--flag', placement: :after_arguments
                      )
                    ],
                    arguments: [
                      Lino::Model::Argument.new('arg1'),
                      Lino::Model::Argument.new('arg2')
                    ],
                    subcommands: [
                      Lino::Model::Subcommand.new('sub')
                    ])
               .string)
        .to(eq('command-with-subcommand sub arg1 arg2 ' \
               '--opt1 val1 --flag'))
    end

    it 'uses mixed option placement when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    options: [
                      Lino::Model::Option.new(
                        '--opt1', 'val1', placement: :after_command
                      ),
                      Lino::Model::Flag.new(
                        '--flag1', placement: :after_arguments
                      ),
                      Lino::Model::Flag.new(
                        '--flag2', placement: :after_subcommands
                      )
                    ],
                    arguments: [
                      Lino::Model::Argument.new('arg1'),
                      Lino::Model::Argument.new('arg2')
                    ],
                    subcommands: [
                      Lino::Model::Subcommand.new('sub')
                    ])
               .string)
        .to(eq('command-with-subcommand --opt1 val1 sub --flag2 ' \
               'arg1 arg2 --flag1'))
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
                      Lino::Model::Option.new('--opt1', 'val1'),
                      Lino::Model::Option.new('--opt2', 'val2'),
                      Lino::Model::Flag.new('--flag'),
                      Lino::Model::Flag.new('-h')
                    ])
               .array)
        .to(eq(%w[command-with-options --opt1 val1 --opt2 val2 --flag -h]))
    end

    it 'uses option separator when provided' do
      expect(described_class
               .new('command-with-overridden-separator',
                    options: [
                      Lino::Model::Option.new('--opt1', 'val1', separator: '='),
                      Lino::Model::Option.new('--opt2', 'val2', separator: ':'),
                      Lino::Model::Option.new('--opt3', 'val3')
                    ])
               .array)
        .to(eq(%w[command-with-overridden-separator
                  --opt1=val1 --opt2:val2 --opt3 val3]))
    end

    it 'ignores option quoting when provided' do
      expect(described_class
               .new('command-with-quoting',
                    options: [
                      Lino::Model::Option.new(
                        '--opt1', 'val1', quoting: '"'
                      ),
                      Lino::Model::Option.new(
                        '--opt2', 'val2', quoting: '"'
                      )
                    ])
               .array)
        .to(eq(%w[command-with-quoting --opt1 val1 --opt2 val2]))
    end

    it 'includes subcommand' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Model::Subcommand.new('sub')
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub]))
    end

    it 'includes subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Model::Subcommand.new(
                        'sub',
                        options: [
                          Lino::Model::Option.new('--opt1', 'val1'),
                          Lino::Model::Option.new('--opt2', 'val2')
                        ]
                      )
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub --opt1 val1 --opt2 val2]))
    end

    it 'uses subcommand option separator for subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Model::Subcommand.new(
                        'sub',
                        options: [
                          Lino::Model::Option.new(
                            '--opt1', 'val1', separator: '='
                          ),
                          Lino::Model::Option.new(
                            '--opt2', 'val2', separator: ':'
                          ),
                          Lino::Model::Option.new(
                            '--opt3', 'val3'
                          )
                        ]
                      )
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub
                  --opt1=val1 --opt2:val2 --opt3 val3]))
    end

    it 'ignores subcommand option quoting for subcommand options' do
      expect(described_class
               .new('command-with-subcommand',
                    subcommands: [
                      Lino::Model::Subcommand.new(
                        'sub',
                        options: [
                          Lino::Model::Option.new(
                            '--opt1', 'val1', quoting: '"'
                          ),
                          Lino::Model::Option.new(
                            '--opt2', 'val2', quoting: '"'
                          )
                        ]
                      )
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub --opt1 val1 --opt2 val2]))
    end

    it 'includes arguments' do
      expect(described_class
               .new('command-with-arguments',
                    arguments: [
                      Lino::Model::Argument.new('arg1'),
                      Lino::Model::Argument.new('arg2'),
                      Lino::Model::Argument.new('arg3')
                    ])
               .array)
        .to(eq(%w[command-with-arguments arg1 arg2 arg3]))
    end

    it 'includes arguments after options' do
      expect(described_class
               .new('command-with-arguments',
                    options: [
                      Lino::Model::Option.new('--opt1', 'val1'),
                      Lino::Model::Flag.new('--flag')
                    ],
                    arguments: [
                      Lino::Model::Argument.new('arg1'),
                      Lino::Model::Argument.new('arg2')
                    ])
               .array)
        .to(eq(%w[command-with-arguments --opt1 val1 --flag arg1 arg2]))
    end

    it 'includes arguments after subcommands' do
      expect(described_class
               .new('command-with-arguments',
                    subcommands: [
                      Lino::Model::Subcommand.new(
                        'sub1',
                        options: [
                          Lino::Model::Option.new('--opt1', 'val1')
                        ]
                      ),
                      Lino::Model::Subcommand.new(
                        'sub2'
                      )
                    ],
                    arguments: [
                      Lino::Model::Argument.new('arg1'),
                      Lino::Model::Argument.new('arg2')
                    ])
               .array)
        .to(eq(%w[command-with-arguments sub1 --opt1 val1 sub2 arg1 arg2]))
    end

    it 'ignores environment variables' do
      expect(described_class
               .new('command-with-environment-variables',
                    environment_variables: [
                      Lino::Model::EnvironmentVariable.new('ENV_VAR1', 'VAL1'),
                      Lino::Model::EnvironmentVariable.new('ENV_VAR2', 'VAL2')
                    ])
               .array)
        .to(eq(%w[command-with-environment-variables]))
    end

    it 'includes command options before subcommands by default' do
      expect(described_class
               .new('command-with-subcommand',
                    options: [
                      Lino::Model::Option.new('--opt1', 'val1'),
                      Lino::Model::Flag.new('--flag')
                    ],
                    subcommands: [
                      Lino::Model::Subcommand.new('sub')
                    ])
               .array)
        .to(eq(%w[command-with-subcommand --opt1 val1 --flag sub]))
    end

    it 'includes command options before subcommands when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    options: [
                      Lino::Model::Option.new(
                        '--opt1', 'val1', placement: :after_command
                      ),
                      Lino::Model::Flag.new('--flag', placement: :after_command)
                    ],
                    subcommands: [
                      Lino::Model::Subcommand.new('sub')
                    ])
               .array)
        .to(eq(%w[command-with-subcommand --opt1 val1 --flag sub]))
    end

    it 'includes command options after subcommands when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    options: [
                      Lino::Model::Option.new(
                        '--opt1', 'val1',
                        placement: :after_subcommands
                      ),
                      Lino::Model::Flag.new(
                        '--flag', placement: :after_subcommands
                      )
                    ],
                    arguments: [
                      Lino::Model::Argument.new('arg1'),
                      Lino::Model::Argument.new('arg2')
                    ],
                    subcommands: [
                      Lino::Model::Subcommand.new('sub')
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub
                  --opt1 val1 --flag arg1 arg2]))
    end

    it 'includes command options after arguments when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    options: [
                      Lino::Model::Option.new(
                        '--opt1', 'val1',
                        placement: :after_arguments
                      ),
                      Lino::Model::Flag.new(
                        '--flag', placement: :after_arguments
                      )
                    ],
                    arguments: [
                      Lino::Model::Argument.new('arg1'),
                      Lino::Model::Argument.new('arg2')
                    ],
                    subcommands: [
                      Lino::Model::Subcommand.new('sub')
                    ])
               .array)
        .to(eq(%w[command-with-subcommand sub arg1 arg2
                  --opt1 val1 --flag]))
    end

    it 'uses mixed option placement when specified' do
      expect(described_class
               .new('command-with-subcommand',
                    options: [
                      Lino::Model::Option.new(
                        '--opt1', 'val1',
                        placement: :after_command
                      ),
                      Lino::Model::Flag.new(
                        '--flag1',
                        placement: :after_arguments
                      ),
                      Lino::Model::Flag.new(
                        '--flag2',
                        placement: :after_subcommands
                      )
                    ],
                    arguments: [
                      Lino::Model::Argument.new('arg1'),
                      Lino::Model::Argument.new('arg2')
                    ],
                    subcommands: [
                      Lino::Model::Subcommand.new('sub')
                    ])
               .array)
        .to(eq(%w[command-with-subcommand --opt1 val1 sub --flag2
                  arg1 arg2 --flag1]))
    end
  end

  describe '#execute' do
    it 'executes the command line with an empty stdin and default ' \
       'stdout and stderr when not provided' do
      command_line = described_class.new(
        'ls',
        options: [
          Lino::Model::Flag.new('-l'),
          Lino::Model::Flag.new('-a')
        ]
      )

      allow(Open4).to(receive(:spawn))

      command_line.execute

      expect(Open4).to(
        have_received(:spawn).with(
          {},
          'ls', '-l', '-a',
          stdin: '',
          stdout: $stdout,
          stderr: $stderr
        )
      )
    end

    it 'uses the supplied stdin, stdout and stderr when provided' do
      command_line = described_class.new(
        'ls',
        options: [
          Lino::Model::Flag.new('-l'),
          Lino::Model::Flag.new('-a')
        ]
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
          'ls', '-l', '-a',
          stdin: stdin,
          stdout: stdout,
          stderr: stderr
        )
      )
    end
  end

  describe '#==' do
    let(:opts) do
      {
        options: [
          Lino::Model::Option.new('--opt1', 'val1')
        ],
        subcommands: [
          Lino::Model::Subcommand.new('sub')
        ],
        arguments: [
          Lino::Model::Argument.new('arg')
        ],
        environment_variables: [
          Lino::Model::EnvironmentVariable.new('ENV_VAR', 'VAL')
        ]
      }
    end

    it 'returns true when class and state equal' do
      first = described_class.new('command', opts)
      second = described_class.new('command', opts)

      expect(first == second).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(described_class).new('command', opts)
      second = described_class.new('command', opts)

      expect(first == second).to(be(false))
    end

    it 'returns false when command different' do
      first = described_class.new('command1', opts)
      second = described_class.new('command2', opts)

      expect(first == second).to(be(false))
    end

    it 'returns false when options different' do
      first = described_class.new(
        'command',
        opts.merge(
          options: [
            Lino::Model::Option.new('--opt1', 'val1')
          ]
        )
      )
      second = described_class.new(
        'command',
        opts.merge(
          options: [
            Lino::Model::Option.new('--opt2', 'val2')
          ]
        )
      )

      expect(first == second).to(be(false))
    end

    it 'returns false when subcommands different' do
      first = described_class.new(
        'command',
        opts.merge(
          subcommands: [
            Lino::Model::Subcommand.new('sub1')
          ]
        )
      )
      second = described_class.new(
        'command',
        opts.merge(
          subcommands: [
            Lino::Model::Subcommand.new('sub2')
          ]
        )
      )

      expect(first == second).to(be(false))
    end

    it 'returns false when arguments different' do
      first = described_class.new(
        'command',
        opts.merge(
          arguments: [
            Lino::Model::Argument.new('arg1')
          ]
        )
      )
      second = described_class.new(
        'command',
        opts.merge(
          arguments: [
            Lino::Model::Argument.new('arg2')
          ]
        )
      )

      expect(first == second).to(be(false))
    end

    it 'returns false when environment variables different' do
      first = described_class.new(
        'command',
        opts.merge(
          environment_variables: [
            Lino::Model::EnvironmentVariable.new('ENV_VAR1', 'VAL1')
          ]
        )
      )
      second = described_class.new(
        'command',
        opts.merge(
          environment_variables: [
            Lino::Model::EnvironmentVariable.new('ENV_VAR2', 'VAL2')
          ]
        )
      )

      expect(first == second).to(be(false))
    end
  end

  describe '#eql?' do
    let(:opts) do
      {
        options: [
          Lino::Model::Option.new('--opt1', 'val1')
        ],
        subcommands: [
          Lino::Model::Subcommand.new('sub')
        ],
        arguments: [
          Lino::Model::Argument.new('arg')
        ],
        environment_variables: [
          Lino::Model::EnvironmentVariable.new('ENV_VAR', 'VAL')
        ]
      }
    end

    it 'returns true when class and state equal' do
      first = described_class.new('command', opts)
      second = described_class.new('command', opts)

      expect(first.eql?(second)).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(described_class).new('command', opts)
      second = described_class.new('command', opts)

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when command different' do
      first = described_class.new('command1', opts)
      second = described_class.new('command2', opts)

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when options different' do
      first = described_class.new(
        'command',
        opts.merge(
          options: [
            Lino::Model::Option.new('--opt1', 'val1')
          ]
        )
      )
      second = described_class.new(
        'command',
        opts.merge(
          options: [
            Lino::Model::Option.new('--opt2', 'val2')
          ]
        )
      )

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when subcommands different' do
      first = described_class.new(
        'command',
        opts.merge(
          subcommands: [
            Lino::Model::Subcommand.new('sub1')
          ]
        )
      )
      second = described_class.new(
        'command',
        opts.merge(
          subcommands: [
            Lino::Model::Subcommand.new('sub2')
          ]
        )
      )

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when arguments different' do
      first = described_class.new(
        'command',
        opts.merge(
          arguments: [
            Lino::Model::Argument.new('arg1')
          ]
        )
      )
      second = described_class.new(
        'command',
        opts.merge(
          arguments: [
            Lino::Model::Argument.new('arg2')
          ]
        )
      )

      expect(first.eql?(second)).to(be(false))
    end

    it 'returns false when environment variables different' do
      first = described_class.new(
        'command',
        opts.merge(
          environment_variables: [
            Lino::Model::EnvironmentVariable.new('ENV_VAR1', 'VAL1')
          ]
        )
      )
      second = described_class.new(
        'command',
        opts.merge(
          environment_variables: [
            Lino::Model::EnvironmentVariable.new('ENV_VAR2', 'VAL2')
          ]
        )
      )

      expect(first.eql?(second)).to(be(false))
    end
  end

  describe '#hash' do
    let(:opts) do
      {
        options: [
          Lino::Model::Option.new('--opt1', 'val1')
        ],
        subcommands: [
          Lino::Model::Subcommand.new('sub')
        ],
        arguments: [
          Lino::Model::Argument.new('arg')
        ],
        environment_variables: [
          Lino::Model::EnvironmentVariable.new('ENV_VAR', 'VAL')
        ]
      }
    end

    it 'has same hash when class and state equal' do
      first = described_class.new('command', opts)
      second = described_class.new('command', opts)

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash when class different' do
      first = Class.new(described_class).new('command', opts)
      second = described_class.new('command', opts)

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when command different' do
      first = described_class.new('command1', opts)
      second = described_class.new('command2', opts)

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when options different' do
      first = described_class.new(
        'command',
        opts.merge(
          options: [
            Lino::Model::Option.new('--opt1', 'val1')
          ]
        )
      )
      second = described_class.new(
        'command',
        opts.merge(
          options: [
            Lino::Model::Option.new('--opt2', 'val2')
          ]
        )
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when subcommands different' do
      first = described_class.new(
        'command',
        opts.merge(
          subcommands: [
            Lino::Model::Subcommand.new('sub1')
          ]
        )
      )
      second = described_class.new(
        'command',
        opts.merge(
          subcommands: [
            Lino::Model::Subcommand.new('sub2')
          ]
        )
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when arguments different' do
      first = described_class.new(
        'command',
        opts.merge(
          arguments: [
            Lino::Model::Argument.new('arg1')
          ]
        )
      )
      second = described_class.new(
        'command',
        opts.merge(
          arguments: [
            Lino::Model::Argument.new('arg2')
          ]
        )
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash when environment variables different' do
      first = described_class.new(
        'command',
        opts.merge(
          environment_variables: [
            Lino::Model::EnvironmentVariable.new('ENV_VAR1', 'VAL1')
          ]
        )
      )
      second = described_class.new(
        'command',
        opts.merge(
          environment_variables: [
            Lino::Model::EnvironmentVariable.new('ENV_VAR2', 'VAL2')
          ]
        )
      )

      expect(first.hash).not_to(eq(second.hash))
    end
  end
end
