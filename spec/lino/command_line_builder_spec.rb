require 'spec_helper'

RSpec.describe Lino::CommandLineBuilder do
  it 'includes the provided command in the resulting command line' do
    command_line = Lino::CommandLineBuilder
        .for_command('command')
        .build

    expect(command_line.to_s).to eq('command')
  end

  it 'includes options after the command separated by a space by default' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-options')
        .with_option('--opt1', 'val1')
        .with_option('--opt2', 'val2')
        .build

    expect(command_line.to_s).to eq('command-with-options --opt1 val1 --opt2 val2')
  end

  it 'uses the specified option separator when provided' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-option-separator')
        .with_option_separator('=')
        .with_option('--opt1', 'val1')
        .with_option('--opt2', 'val2')
        .build

    expect(command_line.to_s).to eq('command-with-option-separator --opt1=val1 --opt2=val2')
  end

  it 'allows the option separator to be overridden on an option by option basis' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-overridden-separator')
        .with_option('--opt1', 'val1', separator: ':')
        .with_option('--opt2', 'val2', separator: '~')
        .with_option('--opt3', 'val3')
        .build

    expect(command_line.to_s)
        .to(eq('command-with-overridden-separator --opt1:val1 --opt2~val2 --opt3 val3'))
  end

  it 'allows the option separator to be overridden for subcommands on an option by option basis' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-overridden-separator')
        .with_subcommand('sub') do |sub|
          sub
            .with_option('--opt1', 'val1', separator: ':')
            .with_option('--opt2', 'val2', separator: '~')
            .with_option('--opt3', 'val3')
        end
        .build

    expect(command_line.to_s)
        .to(eq('command-with-overridden-separator sub --opt1:val1 --opt2~val2 --opt3 val3'))
  end

  it 'uses the specified option quoting character when provided' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-quoting')
        .with_option_quoting('"')
        .with_option('--opt1', 'value1 with spaces')
        .with_option('--opt2', 'value2 with spaces')
        .build

    expect(command_line.to_s)
        .to eq('command-with-quoting ' +
            '--opt1 "value1 with spaces" ' +
            '--opt2 "value2 with spaces"')
  end

  it 'allows the option quoting character to be overridden on an option by option basis' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-overridden-separator')
        .with_option('--opt1', 'value 1', quoting: '"')
        .with_option('--opt2', 'value 2', quoting: "'")
        .with_option('--opt3', 'value3')
        .build

    expect(command_line.to_s)
        .to(eq('command-with-overridden-separator ' +
            '--opt1 "value 1" ' +
            '--opt2 \'value 2\' ' +
            '--opt3 value3'))
  end

  it 'allows the option quoting character to be overridden for subcommands on an option by option basis' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-overridden-separator')
        .with_subcommand('sub') do |sub|
          sub
              .with_option('--opt1', 'value 1', quoting: '"')
              .with_option('--opt2', 'value 2', quoting: "'")
              .with_option('--opt3', 'value3')
        end
        .build

    expect(command_line.to_s)
        .to(eq('command-with-overridden-separator sub ' +
            '--opt1 "value 1" ' +
            '--opt2 \'value 2\' ' +
            '--opt3 value3'))
  end

  it 'treats option specific separators as higher precedence than the global option separator' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-overridden-separator')
        .with_option_separator('=')
        .with_option('--opt1', 'val1', separator: ':')
        .with_option('--opt2', 'val2', separator: '~')
        .with_option('--opt3', 'val3')
        .build

    expect(command_line.to_s)
        .to(eq('command-with-overridden-separator --opt1:val1 --opt2~val2 --opt3=val3'))
  end

  it 'includes flags after the command' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-flags')
        .with_flag('--verbose')
        .with_flag('-h')
        .build

    expect(command_line.to_s).to eq('command-with-flags --verbose -h')
  end

  it 'includes args after the command and all flags and options' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-args')
        .with_flag('-v')
        .with_option('--opt', 'val')
        .with_argument('path/to/file.txt')
        .build

    expect(command_line.to_s).to eq('command-with-args -v --opt val path/to/file.txt')
  end

  it 'includes environment variables before the command' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-environment-variables')
        .with_environment_variable('ENV_VAR1', 'VAL1')
        .with_environment_variable('ENV_VAR2', 'VAL2')
        .build

    expect(command_line.to_s).to(
        eq('ENV_VAR1="VAL1" ENV_VAR2="VAL2" command-with-environment-variables'))
  end

  it 'includes command options and flags before subcommands' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-subcommand')
        .with_flag('-v')
        .with_option('--opt', 'val')
        .with_subcommand('sub1')
        .with_subcommand('sub2')
        .build

    expect(command_line.to_s)
      .to eq('command-with-subcommand -v --opt val sub1 sub2')
  end

  it 'includes args after all subcommands' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-subcommand-and-args')
        .with_subcommand('sub1')
        .with_argument('path/to/file.txt')
        .with_subcommand('sub2')
        .build

    expect(command_line.to_s)
        .to eq('command-with-subcommand-and-args sub1 sub2 path/to/file.txt')
  end

  it 'includes subcommand options and flags with the subcommand' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-subcommands-with-options')
        .with_subcommand('sub1') do |sub1|
          sub1
              .with_flag('-1')
              .with_option('--opt1', 'val1')
        end
        .with_subcommand('sub2') do |sub2|
          sub2
              .with_option('--opt2', 'val2')
              .with_flag('-2')
        end
        .with_option('--opt', 'val')
        .build

    expect(command_line.to_s)
        .to eq('command-with-subcommands-with-options --opt val ' +
            'sub1 -1 --opt1 val1 ' +
            'sub2 --opt2 val2 -2')
  end
end
