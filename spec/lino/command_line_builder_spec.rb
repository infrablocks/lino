# frozen_string_literal: true

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

    expect(command_line.to_s)
      .to eq('command-with-options --opt1 val1 --opt2 val2')
  end

  it 'does not include options without a value' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-options')
                   .with_option('--opt1', 'val1')
                   .with_option('--opt2', nil)
                   .with_option('--opt3', '')
                   .build

    expect(command_line.to_s).to eq('command-with-options --opt1 val1')
  end

  it 'includes repeated options after the command separated by a space ' \
     'by default' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-options')
                   .with_repeated_option('--opt', %w[val1 val2])
                   .build

    expect(command_line.to_s)
      .to eq('command-with-options --opt val1 --opt val2')
  end

  it 'uses the specified option separator when provided' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-option-separator')
                   .with_option_separator('=')
                   .with_option('--opt1', 'val1')
                   .with_option('--opt2', 'val2')
                   .build

    expect(command_line.to_s)
      .to eq('command-with-option-separator --opt1=val1 --opt2=val2')
  end

  it 'uses the specified option separator when provided for repeated options' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-options')
                   .with_option_separator('=')
                   .with_repeated_option('--opt', %w[val1 val2])
                   .build

    expect(command_line.to_s)
      .to eq('command-with-options --opt=val1 --opt=val2')
  end

  it 'allows the option separator to be overridden on an option by ' \
     'option basis' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-overridden-separator')
                   .with_option('--opt1', 'val1', separator: ':')
                   .with_option('--opt2', 'val2', separator: '~')
                   .with_option('--opt3', 'val3')
                   .build

    expect(command_line.to_s)
      .to(eq('command-with-overridden-separator ' \
               '--opt1:val1 --opt2~val2 --opt3 val3'))
  end

  it 'allows the option separator to be overridden on a repeated option ' \
     'by option basis' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-options')
                   .with_repeated_option(
                     '--opt1', %w[val1 val2], separator: ':'
                   )
                   .with_repeated_option(
                     '--opt2', %w[val3 val4], separator: '~'
                   )
                   .with_repeated_option(
                     '--opt3', %w[val5 val6]
                   )
                   .build

    expect(command_line.to_s)
      .to eq('command-with-options --opt1:val1 --opt1:val2 ' \
               '--opt2~val3 --opt2~val4 --opt3 val5 --opt3 val6')
  end

  it 'allows the option separator to be overridden for subcommands on ' \
     'an option by option basis' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-overridden-separator')
                   .with_subcommand('sub') do |sub|
                     sub.with_option('--opt1', 'val1', separator: ':')
                        .with_option('--opt2', 'val2', separator: '~')
                        .with_option('--opt3', 'val3')
                   end
                   .build

    expect(command_line.to_s)
      .to(eq('command-with-overridden-separator sub ' \
               '--opt1:val1 --opt2~val2 --opt3 val3'))
  end

  it 'allows the option separator to be overridden for subcommands on a ' \
     'repeated option by option basis' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-overridden-separator')
                   .with_subcommand('sub') do |sub|
                     sub.with_repeated_option(
                       '--opt1', %w[val1 val2], separator: ':'
                     )
                        .with_repeated_option(
                          '--opt2', %w[val3 val4], separator: '~'
                        )
                        .with_repeated_option(
                          '--opt3', %w[val5 val6]
                        )
                   end
                   .build

    expect(command_line.to_s)
      .to(eq(
            'command-with-overridden-separator sub --opt1:val1 --opt1:val2 ' \
              '--opt2~val3 --opt2~val4 --opt3 val5 --opt3 val6'
          ))
  end

  it 'uses the specified option quoting character when provided' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-quoting')
                   .with_option_quoting('"')
                   .with_option('--opt1', 'value1 with spaces')
                   .with_option('--opt2', 'value2 with spaces')
                   .build

    expect(command_line.to_s)
      .to eq('command-with-quoting --opt1 "value1 with spaces" ' \
               '--opt2 "value2 with spaces"')
  end

  it 'uses the specified option quoting character with repeated options ' \
     'when provided' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-quoting')
                   .with_option_quoting('"')
                   .with_repeated_option(
                     '--opt',
                     ['value with spaces', 'another value with spaces']
                   )
                   .build

    expect(command_line.to_s)
      .to eq('command-with-quoting --opt "value with spaces" ' \
               '--opt "another value with spaces"')
  end

  it 'allows the option quoting character to be overridden on an ' \
     'option by option basis' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-overridden-quoting')
                   .with_option('--opt1', 'value 1', quoting: '"')
                   .with_option('--opt2', 'value 2', quoting: "'")
                   .with_option('--opt3', 'value3')
                   .build

    expect(command_line.to_s)
      .to(eq('command-with-overridden-quoting --opt1 "value 1" ' \
               "--opt2 'value 2' --opt3 value3"))
  end

  it 'allows the option quoting character to be overridden on a repeated ' \
     'option by option basis' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-overridden-quoting')
                   .with_repeated_option(
                     '--opt1', %w[val1 val2], quoting: '"'
                   )
                   .with_repeated_option(
                     '--opt2', %w[val3 val4], quoting: "'"
                   )
                   .build

    expect(command_line.to_s)
      .to eq('command-with-overridden-quoting --opt1 "val1" ' \
               "--opt1 \"val2\" --opt2 'val3' --opt2 'val4'")
  end

  it 'allows the option quoting character to be overridden for subcommands ' \
     'on an option by option basis' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-overridden-quoting')
                   .with_subcommand('sub') do |sub|
                     sub
                       .with_option('--opt1', 'value 1', quoting: '"')
                       .with_option('--opt2', 'value 2', quoting: "'")
                       .with_option('--opt3', 'value3')
                   end
                   .build

    expect(command_line.to_s)
      .to(eq('command-with-overridden-quoting sub --opt1 "value 1" ' \
               '--opt2 \'value 2\' --opt3 value3'))
  end

  it 'allows the option quoting character to be overridden for subcommands ' \
     'on a repeated option by option basis' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-overridden-quoting')
                   .with_subcommand('sub') do |sub|
                     sub.with_repeated_option(
                       '--opt1', %w[val1 val2], quoting: '"'
                     )
                        .with_repeated_option(
                          '--opt2', %w[val3 val4], quoting: "'"
                        )
                        .with_repeated_option(
                          '--opt3', %w[val5 val6]
                        )
                   end
                   .build

    expect(command_line.to_s)
      .to(
        eq('command-with-overridden-quoting sub --opt1 "val1" --opt1 ' \
             '"val2" --opt2 \'val3\' --opt2 \'val4\' --opt3 val5 --opt3 val6')
      )
  end

  it 'treats option specific separators as higher precedence than the ' \
     'global option separator' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-overridden-separator')
                   .with_option_separator('=')
                   .with_option('--opt1', 'val1', separator: ':')
                   .with_option('--opt2', 'val2', separator: '~')
                   .with_option('--opt3', 'val3')
                   .build

    expect(command_line.to_s)
      .to(eq('command-with-overridden-separator --opt1:val1 --opt2~val2 ' \
               '--opt3=val3'))
  end

  it 'treats repeated option specific separators as higher precedence than ' \
     'the global option separator' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-overridden-separator')
                   .with_option_separator('=')
                   .with_repeated_option(
                     '--opt1', %w[val1 val2], separator: ':'
                   )
                   .with_repeated_option(
                     '--opt2', %w[val3 val4], separator: '~'
                   )
                   .with_repeated_option(
                     '--opt3', %w[val5 val6]
                   )
                   .build

    expect(command_line.to_s)
      .to(eq('command-with-overridden-separator --opt1:val1 --opt1:val2 ' \
               '--opt2~val3 --opt2~val4 --opt3=val5 --opt3=val6'))
  end

  it 'allows options and repeated options to be used together' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-options')
                   .with_repeated_option(
                     '--opt1', %w[val1 val2]
                   )
                   .with_option(
                     '--opt2', 'val3'
                   )
                   .build

    expect(command_line.to_s)
      .to eq('command-with-options --opt1 val1 --opt1 val2 --opt2 val3')
  end

  it 'allows options and repeated option to work together for subcommands' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-options')
                   .with_subcommand('sub') do |sub|
                     sub
                       .with_repeated_option(
                         '--opt1', %w[val1 val2], quoting: '"'
                       )
                       .with_option('--opt2', 'val3')
                   end
                   .build

    expect(command_line.to_s)
      .to(eq('command-with-options sub --opt1 "val1" --opt1 "val2" ' \
             '--opt2 val3'))
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

    expect(command_line.to_s)
      .to eq('command-with-args -v --opt val path/to/file.txt')
  end

  it 'includes multiple args after the command and all flags and options' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-args')
                   .with_flag('-v')
                   .with_option('--opt', 'val')
                   .with_arguments(%w[path/to/file1.txt path/to/file2.txt])
                   .build

    expect(command_line.to_s)
      .to eq('command-with-args -v --opt val ' \
             'path/to/file1.txt path/to/file2.txt')
  end

  it 'ignores empty args when processing arguments' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-args')
                   .with_flag('-v')
                   .with_option('--opt', 'val')
                   .with_arguments(
                     [
                       'path/to/file1.txt', '', nil, 'path/to/file2.txt'
                     ]
                   )
                   .build

    expect(command_line.to_s)
      .to eq('command-with-args -v --opt val ' \
             'path/to/file1.txt path/to/file2.txt')
  end

  it 'allows multiple args and args to be used together' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-args')
                   .with_flag('-v')
                   .with_option('--opt', 'val')
                   .with_arguments(%w[path/to/file1.txt path/to/file2.txt])
                   .with_argument('another_file.txt')
                   .build

    expect(command_line.to_s)
      .to eq('command-with-args -v --opt val ' \
             'path/to/file1.txt path/to/file2.txt another_file.txt')
  end

  it 'includes environment variables before the command' do
    command_line = Lino::CommandLineBuilder
                   .for_command('command-with-environment-variables')
                   .with_environment_variable(
                     'ENV_VAR1', 'VAL1'
                   )
                   .with_environment_variable(
                     'ENV_VAR2', 'VAL2'
                   )
                   .with_environment_variable(
                     'ENV_VAR3', '"[1,2,3]"'
                   )
                   .build

    expect(command_line.to_s).to(
      eq('ENV_VAR1="VAL1" ENV_VAR2="VAL2" ENV_VAR3="\"[1,2,3]\"" ' \
         'command-with-environment-variables')
    )
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
    builder = Lino::CommandLineBuilder
              .for_command('command-with-subcommands-with-options')
    builder = builder.with_subcommand('sub1') do |sub1|
      sub1.with_flag('-1')
          .with_option('--opt1', 'val1')
    end
    builder = builder.with_subcommand('sub2') do |sub2|
      sub2.with_option('--opt2', 'val2')
          .with_flag('-2')
    end
    builder = builder.with_option('--opt', 'val')
    result = builder.build

    expect(result.to_s)
      .to eq('command-with-subcommands-with-options --opt val sub1 -1 ' \
               '--opt1 val1 sub2 --opt2 val2 -2')
  end

  it 'allows multiple subcommands to be passed at once ' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-subcommand')
             .with_flag('-v')
             .with_option('--opt', 'val')
             .with_subcommands(%w[sub1 sub2])
             .build

    expect(result.to_s)
      .to eq('command-with-subcommand -v --opt val sub1 sub2')
  end

  it 'applies subcommand block to last subcommand when multiple ' \
     'subcommands passed' do
    builder = Lino::CommandLineBuilder
              .for_command('command-with-subcommand')
              .with_flag('-v')
              .with_option('--opt', 'val')
              .with_argument('/some/file.txt')

    builder = builder.with_subcommands(%w[sub1 sub2]) do |sub|
      sub.with_option('--subopt', 'subval')
    end

    result = builder.build

    expect(result.to_s)
      .to eq('command-with-subcommand -v --opt val sub1 sub2 --subopt subval ' \
               '/some/file.txt')
  end
end
