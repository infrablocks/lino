# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lino::CommandLineBuilder do
  it 'includes the provided command in the resulting command line' do
    result = Lino::CommandLineBuilder
             .for_command('command')
             .build

    expect(result.to_s).to eq('command')
  end

  it 'includes single options after the command separated by a space ' \
     'by default' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-options')
             .with_option('--opt1', 'val1')
             .with_option('--opt2', 'val2')
             .build

    expect(result.to_s)
      .to eq('command-with-options --opt1 val1 --opt2 val2')
  end

  it 'ignores single options without a value' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-options')
             .with_option('--opt1', 'val1')
             .with_option('--opt2', nil)
             .with_option('--opt3', '')
             .build

    expect(result.to_s).to eq('command-with-options --opt1 val1')
  end

  it 'includes repeated options after the command separated by a space ' \
     'by default' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-options')
             .with_repeated_option('--opt', %w[val1 val2])
             .build

    expect(result.to_s)
      .to eq('command-with-options --opt val1 --opt val2')
  end

  it 'uses the specified option separator when provided for single options' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-option-separator')
             .with_option_separator('=')
             .with_option('--opt1', 'val1')
             .with_option('--opt2', 'val2')
             .build

    expect(result.to_s)
      .to eq('command-with-option-separator --opt1=val1 --opt2=val2')
  end

  it 'uses the specified option separator when provided for repeated options' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-options')
             .with_option_separator('=')
             .with_repeated_option('--opt', %w[val1 val2])
             .build

    expect(result.to_s)
      .to eq('command-with-options --opt=val1 --opt=val2')
  end

  it 'allows the option separator to be overridden for each single option' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-overridden-separator')
             .with_option('--opt1', 'val1', separator: ':')
             .with_option('--opt2', 'val2', separator: '~')
             .with_option('--opt3', 'val3')
             .build

    expect(result.to_s)
      .to(eq('command-with-overridden-separator ' \
               '--opt1:val1 --opt2~val2 --opt3 val3'))
  end

  it 'allows the option separator to be overridden for each repeated option' do
    result = Lino::CommandLineBuilder
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

    expect(result.to_s)
      .to eq('command-with-options --opt1:val1 --opt1:val2 ' \
               '--opt2~val3 --opt2~val4 --opt3 val5 --opt3 val6')
  end

  it 'allows the option separator to be overridden for single options ' \
     'on subcommands' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-overridden-separator')
             .with_subcommand('sub') do |sub|
      sub.with_option('--opt1', 'val1', separator: ':')
         .with_option('--opt2', 'val2', separator: '~')
         .with_option('--opt3', 'val3')
    end
             .build

    expect(result.to_s)
      .to(eq('command-with-overridden-separator sub ' \
               '--opt1:val1 --opt2~val2 --opt3 val3'))
  end

  it 'allows the option separator to be overridden for repeated options ' \
     'on subcommands' do
    result = Lino::CommandLineBuilder
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

    expect(result.to_s)
      .to(eq(
            'command-with-overridden-separator sub --opt1:val1 --opt1:val2 ' \
                  '--opt2~val3 --opt2~val4 --opt3 val5 --opt3 val6'
          ))
  end

  it 'uses the specified option quoting character for single options ' \
     'when provided' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-quoting')
             .with_option_quoting('"')
             .with_option('--opt1', 'value1 with spaces')
             .with_option('--opt2', 'value2 with spaces')
             .build

    expect(result.to_s)
      .to eq('command-with-quoting --opt1 "value1 with spaces" ' \
               '--opt2 "value2 with spaces"')
  end

  it 'uses the specified option quoting character for repeated options ' \
     'when provided' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-quoting')
             .with_option_quoting('"')
             .with_repeated_option(
               '--opt',
               ['value with spaces', 'another value with spaces']
             )
             .build

    expect(result.to_s)
      .to eq('command-with-quoting --opt "value with spaces" ' \
               '--opt "another value with spaces"')
  end

  it 'allows the option quoting character to be overridden ' \
     'for single options' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-overridden-quoting')
             .with_option('--opt1', 'value 1', quoting: '"')
             .with_option('--opt2', 'value 2', quoting: "'")
             .with_option('--opt3', 'value3')
             .build

    expect(result.to_s)
      .to(eq('command-with-overridden-quoting --opt1 "value 1" ' \
               "--opt2 'value 2' --opt3 value3"))
  end

  it 'allows the option quoting character to be overridden ' \
     'for repeated options' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-overridden-quoting')
             .with_repeated_option(
               '--opt1', %w[val1 val2], quoting: '"'
             )
             .with_repeated_option(
               '--opt2', %w[val3 val4], quoting: "'"
             )
             .build

    expect(result.to_s)
      .to eq('command-with-overridden-quoting --opt1 "val1" ' \
               "--opt1 \"val2\" --opt2 'val3' --opt2 'val4'")
  end

  it 'allows the option quoting character to be overridden ' \
     'for single options on subcommands' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-overridden-quoting')
             .with_subcommand('sub') do |sub|
      sub
        .with_option('--opt1', 'value 1', quoting: '"')
        .with_option('--opt2', 'value 2', quoting: "'")
        .with_option('--opt3', 'value3')
    end
             .build

    expect(result.to_s)
      .to(eq('command-with-overridden-quoting sub --opt1 "value 1" ' \
               '--opt2 \'value 2\' --opt3 value3'))
  end

  it 'allows the option quoting character to be overridden ' \
     'for repeated options on subcommands' do
    result = Lino::CommandLineBuilder
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

    expect(result.to_s)
      .to(
        eq('command-with-overridden-quoting sub --opt1 "val1" --opt1 "val2" ' \
             '--opt2 \'val3\' --opt2 \'val4\' --opt3 val5 --opt3 val6')
      )
  end

  it 'treats option specific separators as higher precedence than the ' \
     'global option separator for single options' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-overridden-separator')
             .with_option_separator('=')
             .with_option('--opt1', 'val1', separator: ':')
             .with_option('--opt2', 'val2', separator: '~')
             .with_option('--opt3', 'val3')
             .build

    expect(result.to_s)
      .to(eq('command-with-overridden-separator --opt1:val1 --opt2~val2 ' \
               '--opt3=val3'))
  end

  it 'treats option specific separators as higher precedence than ' \
     'the global option separator for repeated options' do
    result = Lino::CommandLineBuilder
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

    expect(result.to_s)
      .to(eq('command-with-overridden-separator --opt1:val1 --opt1:val2 ' \
               '--opt2~val3 --opt2~val4 --opt3=val5 --opt3=val6'))
  end

  it 'allows single options and repeated options to be used together' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-options')
             .with_repeated_option(
               '--opt1', %w[val1 val2]
             )
             .with_option(
               '--opt2', 'val3'
             )
             .build

    expect(result.to_s)
      .to eq('command-with-options --opt1 val1 --opt1 val2 --opt2 val3')
  end

  it 'allows single options and repeated options to be used together ' \
     'for subcommands' do
    builder = Lino::CommandLineBuilder
              .for_command('command-with-options')

    builder = builder.with_subcommand('sub') do |sub|
      sub
        .with_repeated_option(
          '--opt1', %w[val1 val2], quoting: '"'
        )
        .with_option('--opt2', 'val3')
    end

    result = builder.build

    expect(result.to_s)
      .to(eq('command-with-options sub --opt1 "val1" --opt1 "val2" ' \
             '--opt2 val3'))
  end

  it 'includes single flags after the command' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-flags')
             .with_flag('--verbose')
             .with_flag('-h')
             .build

    expect(result.to_s).to eq('command-with-flags --verbose -h')
  end

  it 'includes multiple flags after the command' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-flags')
             .with_flags(['--verbose', '-h'])
             .build

    expect(result.to_s).to eq('command-with-flags --verbose -h')
  end

  it 'ignores nil flags when passing a single flag' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-flags')
             .with_flag(nil)
             .with_flag('-h')
             .build

    expect(result.to_s).to eq('command-with-flags -h')
  end

  it 'ignores empty flags when passing a single flag' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-flags')
             .with_flag('')
             .with_flag('-h')
             .build

    expect(result.to_s).to eq('command-with-flags -h')
  end

  it 'ignores nil and empty flags when passing multiple flags' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-flags')
             .with_flags(['--verbose', nil, '', '-h'])
             .build

    expect(result.to_s).to eq('command-with-flags --verbose -h')
  end

  it 'does nothing when nil or empty array provided when ' \
     'passing multiple flags' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-flags')
             .with_flags(nil)
             .with_flags([])
             .build

    expect(result.to_s).to eq('command-with-flags')
  end

  it 'includes single args after the command and all flags and options' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-args')
             .with_flag('-v')
             .with_option('--opt', 'val')
             .with_argument('path/to/file.txt')
             .build

    expect(result.to_s)
      .to eq('command-with-args -v --opt val path/to/file.txt')
  end

  it 'includes multiple args after the command and all flags and options' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-args')
             .with_flag('-v')
             .with_option('--opt', 'val')
             .with_arguments(%w[path/to/file1.txt path/to/file2.txt])
             .build

    expect(result.to_s)
      .to eq('command-with-args -v --opt val ' \
             'path/to/file1.txt path/to/file2.txt')
  end

  it 'ignores nil args when passing a single arg' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-args')
             .with_flag('-v')
             .with_option('--opt', 'val')
             .with_argument(nil)
             .build

    expect(result.to_s)
      .to eq('command-with-args -v --opt val')
  end

  it 'ignores empty args when passing a single arg' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-args')
             .with_flag('-v')
             .with_option('--opt', 'val')
             .with_argument('')
             .build

    expect(result.to_s)
      .to eq('command-with-args -v --opt val')
  end

  it 'ignores nil and empty args when passing multiple args' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-args')
             .with_flag('-v')
             .with_option('--opt', 'val')
             .with_arguments(
               [
                 'path/to/file1.txt', '', nil, 'path/to/file2.txt'
               ]
             )
             .build

    expect(result.to_s)
      .to eq('command-with-args -v --opt val ' \
             'path/to/file1.txt path/to/file2.txt')
  end

  it 'does nothing when nil or empty arguments provided when ' \
     'passing multiple arguments' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-flags')
             .with_arguments(nil)
             .with_arguments([])
             .build

    expect(result.to_s).to eq('command-with-flags')
  end

  it 'allows single and multiple args to be used together' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-args')
             .with_flag('-v')
             .with_option('--opt', 'val')
             .with_arguments(%w[path/to/file1.txt path/to/file2.txt])
             .with_argument('another_file.txt')
             .build

    expect(result.to_s)
      .to eq('command-with-args -v --opt val ' \
             'path/to/file1.txt path/to/file2.txt another_file.txt')
  end

  it 'includes environment variables before the command' do
    result = Lino::CommandLineBuilder
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

    expect(result.to_s).to(
      eq('ENV_VAR1="VAL1" ENV_VAR2="VAL2" ENV_VAR3="\"[1,2,3]\"" ' \
           'command-with-environment-variables')
    )
  end

  it 'includes command options and flags before subcommands by default' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-subcommand')
             .with_flag('-v')
             .with_option('--opt', 'val')
             .with_subcommand('sub1')
             .with_subcommand('sub2')
             .build

    expect(result.to_s)
      .to eq('command-with-subcommand -v --opt val sub1 sub2')
  end

  it 'includes command options and flags before subcommands when specified' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-subcommand')
             .with_options_after_command
             .with_flag('-v')
             .with_option('--opt', 'val')
             .with_subcommand('sub1')
             .with_subcommand('sub2')
             .build

    expect(result.to_s)
      .to eq('command-with-subcommand -v --opt val sub1 sub2')
  end

  it 'includes command options and flags after subcommands when specified' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-subcommand')
             .with_options_after_subcommands
             .with_flag('-v')
             .with_option('--opt', 'val')
             .with_subcommand('sub1')
             .with_subcommand('sub2')
             .build

    expect(result.to_s)
      .to eq('command-with-subcommand sub1 sub2 -v --opt val')
  end

  it 'includes command options and flags after arguments when specified' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-subcommand')
             .with_options_after_arguments
             .with_flag('-v')
             .with_option('--opt', 'val')
             .with_argument('/some/path.txt')
             .with_subcommand('sub1')
             .with_subcommand('sub2')
             .build

    expect(result.to_s)
      .to eq('command-with-subcommand sub1 sub2 /some/path.txt -v --opt val')
  end

  it 'includes args after all subcommands' do
    result = Lino::CommandLineBuilder
             .for_command('command-with-subcommand-and-args')
             .with_subcommand('sub1')
             .with_argument('path/to/file.txt')
             .with_subcommand('sub2')
             .build

    expect(result.to_s)
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
