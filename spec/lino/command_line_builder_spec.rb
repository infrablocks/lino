# frozen_string_literal: true

require 'spec_helper'

class AppliableOption
  def initialize(option, value)
    @option = option
    @value = value
  end

  def apply(command)
    command.with_option(@option, @value)
  end
end

RSpec.describe Lino::CommandLineBuilder do
  describe 'command' do
    it 'includes the provided command in the resulting command line' do
      expect(
        described_class
          .for_command('command')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new('command')))
    end
  end

  describe 'appliables' do
    it 'applies single appliable' do
      expect(
        described_class
          .for_command('command-with-options')
          .with_appliable(
            AppliableOption.new('--opt', 'val')
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 options: [
                   Lino::Model::Option.new('--opt', 'val')
                 ]
               )))
    end

    it 'does nothing when nil single appliable provided' do
      expect(
        described_class
          .for_command('command-with-options')
          .with_appliable(nil)
          .build
      )
        .to(eq(Lino::Model::CommandLine.new('command-with-options')))
    end

    it 'applies multiple appliables' do
      expect(
        described_class
          .for_command('command-with-options')
          .with_appliables(
            [
              AppliableOption.new('--opt1', 'val1'),
              AppliableOption.new('--opt2', 'val2')
            ]
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 options: [
                   Lino::Model::Option.new('--opt1', 'val1'),
                   Lino::Model::Option.new('--opt2', 'val2')
                 ]
               )))
    end

    it 'does nothing when nil multiple appliables provided' do
      expect(
        described_class
          .for_command('command-with-options')
          .with_appliables(nil)
          .build
      )
        .to(eq(Lino::Model::CommandLine.new('command-with-options')))
    end
  end

  describe 'subcommands' do
    it 'includes single appliable on subcommands' do
      builder = described_class
                .for_command('command-with-options')
      builder = builder.with_subcommand('sub') do |sub|
        sub
          .with_appliable(
            AppliableOption.new('--opt', 'val')
          )
      end
      result = builder.build

      expect(result)
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 subcommands: [
                   Lino::Model::Subcommand.new(
                     'sub',
                     options: [
                       Lino::Model::Option.new('--opt', 'val')
                     ]
                   )
                 ]
               )))
    end

    it 'does nothing when nil single appliable provided on subcommand' do
      builder = described_class
                .for_command('command-with-options')
      builder = builder.with_subcommand('sub') do |sub|
        sub.with_appliable(nil)
      end
      result = builder.build

      expect(result)
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 subcommands: [
                   Lino::Model::Subcommand.new('sub')
                 ]
               )))
    end

    it 'includes multiple appliables on subcommand' do
      builder = described_class
                .for_command('command-with-options')
      builder = builder.with_subcommand('sub') do |sub|
        sub
          .with_appliables(
            [
              AppliableOption.new('--opt1', 'val1'),
              AppliableOption.new('--opt2', 'val2')
            ]
          )
      end
      result = builder.build

      expect(result)
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 subcommands: [
                   Lino::Model::Subcommand.new(
                     'sub',
                     options: [
                       Lino::Model::Option.new('--opt1', 'val1'),
                       Lino::Model::Option.new('--opt2', 'val2')
                     ]
                   )
                 ]
               )))
    end

    it 'does nothing when nil multiple appliables provided on subcommand' do
      builder = described_class
                .for_command('command-with-options')
      builder = builder.with_subcommand('sub') do |sub|
        sub.with_appliables(nil)
      end
      result = builder.build

      expect(result)
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 subcommands: [
                   Lino::Model::Subcommand.new('sub')
                 ]
               )))
    end

    it 'allows single options, multiple options and repeated options ' \
       'to be used together for subcommands' do
      builder = described_class
                .for_command('command-with-options')

      builder = builder.with_subcommand('sub') do |sub|
        sub
          .with_repeated_option(
            '--opt1', %w[val1 val2], quoting: '"'
          )
          .with_option('--opt2', 'val3')
          .with_options(
            {
              '--opt3' => 'val4',
              '--opt4' => 'val5'
            }
          )
      end

      result = builder.build

      expect(result)
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 subcommands: [
                   Lino::Model::Subcommand.new(
                     'sub',
                     options: [
                       Lino::Model::Option.new(
                         '--opt1', 'val1', quoting: '"'
                       ),
                       Lino::Model::Option.new(
                         '--opt1', 'val2', quoting: '"'
                       ),
                       Lino::Model::Option.new('--opt2', 'val3'),
                       Lino::Model::Option.new('--opt3', 'val4'),
                       Lino::Model::Option.new('--opt4', 'val5')
                     ]
                   )
                 ]
               )))
    end

    it 'ignores nil repeated option values on subcommands' do
      builder = described_class
                .for_command('command-with-options')

      builder = builder.with_subcommand('sub') do |sub|
        sub
          .with_repeated_option(
            '--opt', ['val1', nil, 'val2']
          )
      end

      result = builder.build

      expect(result)
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 subcommands: [
                   Lino::Model::Subcommand.new(
                     'sub',
                     options: [
                       Lino::Model::Option.new('--opt', 'val1'),
                       Lino::Model::Option.new('--opt', 'val2')
                     ]
                   )
                 ]
               )))
    end

    it 'ignores nil and empty subcommands when passing a single subcommand' do
      expect(
        described_class
          .for_command('command-without-subcommands')
          .with_subcommand(nil)
          .with_subcommand('')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-without-subcommands'
               )))
    end

    it 'allows multiple subcommands to be passed at once' do
      expect(
        described_class
          .for_command('command-with-subcommand')
          .with_flag('-v')
          .with_option('--opt', 'val')
          .with_subcommands(%w[sub1 sub2])
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-subcommand',
                 options: [
                   Lino::Model::Flag.new('-v'),
                   Lino::Model::Option.new('--opt', 'val')
                 ],
                 subcommands: [
                   Lino::Model::Subcommand.new('sub1'),
                   Lino::Model::Subcommand.new('sub2')
                 ]
               )))
    end

    it 'applies subcommand block to last subcommand when multiple ' \
       'subcommands passed' do
      builder = described_class
                .for_command('command-with-subcommand')
                .with_flag('-v')
                .with_option('--opt', 'val')
                .with_argument('/some/file.txt')

      builder = builder.with_subcommands(%w[sub1 sub2]) do |sub|
        sub.with_option('--subopt', 'subval')
      end

      result = builder.build

      expect(result)
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-subcommand',
                 options: [
                   Lino::Model::Flag.new('-v'),
                   Lino::Model::Option.new('--opt', 'val')
                 ],
                 arguments: [
                   Lino::Model::Argument.new('/some/file.txt')
                 ],
                 subcommands: [
                   Lino::Model::Subcommand.new('sub1'),
                   Lino::Model::Subcommand.new(
                     'sub2',
                     options: [
                       Lino::Model::Option.new('--subopt', 'subval')
                     ]
                   )
                 ]
               )))
    end

    it 'ignores nil subcommands when passing multiple subcommands' do
      expect(
        described_class
          .for_command('command-with-subcommands')
          .with_subcommands(
            [
              'sub1', nil, 'sub2'
            ]
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-subcommands',
                 subcommands: [
                   Lino::Model::Subcommand.new('sub1'),
                   Lino::Model::Subcommand.new('sub2')
                 ]
               )))
    end

    it 'does nothing when nil or empty subcommands provided when passing ' \
       'multiple subcommands' do
      expect(
        described_class
          .for_command('command-without-subcommands')
          .with_subcommands(nil)
          .with_subcommands([])
          .with_subcommands([]) { |s| s }
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-without-subcommands'
               )))
    end
  end

  describe 'options' do
    it 'includes single options after the command' do
      expect(
        described_class
          .for_command('command-with-options')
          .with_option('--opt1', 'val1')
          .with_option('--opt2', 'val2')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 options: [
                   Lino::Model::Option.new('--opt1', 'val1'),
                   Lino::Model::Option.new('--opt2', 'val2')
                 ]
               )))
    end

    it 'ignores nil single options' do
      expect(
        described_class
          .for_command('command-with-options')
          .with_option('--opt1', 'val1')
          .with_option('--opt2', nil)
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 options: [
                   Lino::Model::Option.new('--opt1', 'val1')
                 ]
               )))
    end

    it 'includes multiple options passed as a hash after the command' do
      expect(
        described_class
          .for_command('command-with-options')
          .with_options(
            {
              '--opt1' => 'val1',
              '--opt2' => 'val2'
            }
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 options: [
                   Lino::Model::Option.new('--opt1', 'val1'),
                   Lino::Model::Option.new('--opt2', 'val2')
                 ]
               )))
    end

    it 'includes multiple options passed as an array after the command' do
      expect(
        described_class
          .for_command('command-with-options')
          .with_options(
            [
              {
                option: '--opt1',
                value: 'val1'
              },
              {
                option: '--opt2',
                value: 'val2'
              }
            ]
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 options: [
                   Lino::Model::Option.new('--opt1', 'val1'),
                   Lino::Model::Option.new('--opt2', 'val2')
                 ]
               )))
    end

    it 'ignores nil multiple option values passed as a hash' do
      expect(
        described_class
          .for_command('command-with-options')
          .with_options(
            {
              '--opt1' => 'val1',
              '--opt3' => nil,
              '--opt4' => 'val4'
            }
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 options: [
                   Lino::Model::Option.new('--opt1', 'val1'),
                   Lino::Model::Option.new('--opt4', 'val4')
                 ]
               )))
    end

    it 'ignores multiple options passed as an array without a value' do
      result = described_class
               .for_command('command-with-options')
               .with_options(
                 [
                   { option: '--opt1', value: 'val1' },
                   { option: '--opt3', value: nil },
                   { option: '--opt4', value: 'val4' }
                 ]
               )
               .build

      expect(result)
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 options: [
                   Lino::Model::Option.new('--opt1', 'val1'),
                   Lino::Model::Option.new('--opt4', 'val4')
                 ]
               )))
    end

    it 'does nothing when nil or empty options provided when ' \
       'passing multiple options' do
      expect(
        described_class
          .for_command('command-with-options')
          .with_options(nil)
          .with_options([])
          .with_options({})
          .build
      )
        .to(eq(Lino::Model::CommandLine.new('command-with-options')))
    end

    it 'includes repeated options after the command' do
      expect(
        described_class
          .for_command('command-with-options')
          .with_repeated_option('--opt', %w[val1 val2])
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 options: [
                   Lino::Model::Option.new('--opt', 'val1'),
                   Lino::Model::Option.new('--opt', 'val2')
                 ]
               )))
    end

    it 'ignores nil repeated option values' do
      expect(
        described_class
          .for_command('command-with-options')
          .with_repeated_option(
            '--opt', ['val1', nil, 'val2']
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 options: [
                   Lino::Model::Option.new('--opt', 'val1'),
                   Lino::Model::Option.new('--opt', 'val2')
                 ]
               )))
    end

    it 'allows single options, multiple options and repeated options ' \
       'to be used together' do
      expect(
        described_class
          .for_command('command-with-options')
          .with_repeated_option(
            '--opt1', %w[val1 val2]
          )
          .with_option(
            '--opt2', 'val3'
          )
          .with_options(
            {
              '--opt3' => 'val4',
              '--opt4' => 'val5'
            }
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 options: [
                   Lino::Model::Option.new('--opt1', 'val1'),
                   Lino::Model::Option.new('--opt1', 'val2'),
                   Lino::Model::Option.new('--opt2', 'val3'),
                   Lino::Model::Option.new('--opt3', 'val4'),
                   Lino::Model::Option.new('--opt4', 'val5')
                 ]
               )))
    end
  end

  describe 'option config' do
    it 'uses the specified option separator when provided when passing ' \
       'single options' do
      expect(
        described_class
          .for_command('command-with-option-separator')
          .with_option_separator('=')
          .with_option('--opt1', 'val1')
          .with_option('--opt2', 'val2')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-option-separator',
                 options: [
                   Lino::Model::Option.new(
                     '--opt1', 'val1', separator: '='
                   ),
                   Lino::Model::Option.new(
                     '--opt2', 'val2', separator: '='
                   )
                 ]
               )))
    end

    it 'uses the specified option separator when provided when passing ' \
       'multiple options' do
      expect(
        described_class
          .for_command('command-with-option-separator')
          .with_option_separator('=')
          .with_options(
            {
              '--opt1' => 'val1',
              '--opt2' => 'val2'
            }
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-option-separator',
                 options: [
                   Lino::Model::Option.new(
                     '--opt1', 'val1', separator: '='
                   ),
                   Lino::Model::Option.new(
                     '--opt2', 'val2', separator: '='
                   )
                 ]
               )))
    end

    it 'uses the specified option separator when provided when passing ' \
       'repeated options' do
      expect(
        described_class
          .for_command('command-with-options')
          .with_option_separator('=')
          .with_repeated_option('--opt', %w[val1 val2])
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 options: [
                   Lino::Model::Option.new('--opt', 'val1', separator: '='),
                   Lino::Model::Option.new('--opt', 'val2', separator: '=')
                 ]
               )))
    end

    it 'allows the option separator to be overridden for each single option' do
      expect(
        described_class
          .for_command('command-with-overridden-separator')
          .with_option('--opt1', 'val1', separator: ':')
          .with_option('--opt2', 'val2', separator: '~')
          .with_option('--opt3', 'val3')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-overridden-separator',
                 options: [
                   Lino::Model::Option.new('--opt1', 'val1', separator: ':'),
                   Lino::Model::Option.new('--opt2', 'val2', separator: '~'),
                   Lino::Model::Option.new('--opt3', 'val3')
                 ]
               )))
    end

    it 'allows the option separator to be overridden for each multiple ' \
       'option when passed as an array' do
      expect(
        described_class
          .for_command('command-with-overridden-separator')
          .with_options(
            [
              {
                option: '--opt1',
                value: 'val1',
                separator: ':'
              },
              {
                option: '--opt2',
                value: 'val2',
                separator: '~'
              },
              {
                option: '--opt3',
                value: 'val3'
              }
            ]
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-overridden-separator',
                 options: [
                   Lino::Model::Option.new('--opt1', 'val1', separator: ':'),
                   Lino::Model::Option.new('--opt2', 'val2', separator: '~'),
                   Lino::Model::Option.new('--opt3', 'val3')
                 ]
               )))
    end

    it 'allows the option separator to be overridden for each repeated ' \
       'option' do
      expect(
        described_class
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
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-options',
                 options: [
                   Lino::Model::Option.new(
                     '--opt1', 'val1', separator: ':'
                   ),
                   Lino::Model::Option.new(
                     '--opt1', 'val2', separator: ':'
                   ),
                   Lino::Model::Option.new(
                     '--opt2', 'val3', separator: '~'
                   ),
                   Lino::Model::Option.new(
                     '--opt2', 'val4', separator: '~'
                   ),
                   Lino::Model::Option.new(
                     '--opt3', 'val5'
                   ),
                   Lino::Model::Option.new(
                     '--opt3', 'val6'
                   )
                 ]
               )))
    end

    it 'allows the option separator to be overridden for single options ' \
       'on subcommands' do
      result = described_class
               .for_command('command-with-overridden-separator')
               .with_subcommand('sub') do |sub|
        sub.with_option('--opt1', 'val1', separator: ':')
           .with_option('--opt2', 'val2', separator: '~')
           .with_option('--opt3', 'val3')
      end
                 .build

      expect(result)
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-overridden-separator',
                 subcommands: [
                   Lino::Model::Subcommand.new(
                     'sub',
                     options: [
                       Lino::Model::Option.new('--opt1', 'val1',
                                               separator: ':'),
                       Lino::Model::Option.new('--opt2', 'val2',
                                               separator: '~'),
                       Lino::Model::Option.new('--opt3', 'val3')
                     ]
                   )
                 ]
               )))
    end

    it 'allows the option separator to be overridden for multiple options ' \
       'passed as an array on subcommands' do
      builder = described_class
                .for_command('command-with-overridden-separator')
      builder = builder.with_subcommand('sub') do |sub|
        sub
          .with_options(
            [
              { option: '--opt1', value: 'val1', separator: ':' },
              { option: '--opt2', value: 'val2', separator: '~' },
              { option: '--opt3', value: 'val3' }
            ]
          )
      end
      result = builder.build

      expect(result)
        .to(
          eq(
            Lino::Model::CommandLine.new(
              'command-with-overridden-separator',
              subcommands: [
                Lino::Model::Subcommand.new(
                  'sub',
                  options: [
                    Lino::Model::Option.new('--opt1', 'val1', separator: ':'),
                    Lino::Model::Option.new('--opt2', 'val2', separator: '~'),
                    Lino::Model::Option.new('--opt3', 'val3')
                  ]
                )
              ]
            )
          )
        )
    end

    it 'allows the option separator to be overridden for repeated options ' \
       'on subcommands' do
      result = described_class
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

      expect(result)
        .to(
          eq(
            Lino::Model::CommandLine.new(
              'command-with-overridden-separator',
              subcommands: [
                Lino::Model::Subcommand.new(
                  'sub',
                  options: [
                    Lino::Model::Option.new('--opt1', 'val1', separator: ':'),
                    Lino::Model::Option.new('--opt1', 'val2', separator: ':'),
                    Lino::Model::Option.new('--opt2', 'val3', separator: '~'),
                    Lino::Model::Option.new('--opt2', 'val4', separator: '~'),
                    Lino::Model::Option.new('--opt3', 'val5'),
                    Lino::Model::Option.new('--opt3', 'val6')
                  ]
                )
              ]
            )
          )
        )
    end

    it 'uses the specified option quoting character for single options ' \
       'when provided' do
      expect(
        described_class
          .for_command('command-with-quoting')
          .with_option_quoting('"')
          .with_option('--opt1', 'value1 with spaces')
          .with_option('--opt2', 'value2 with spaces')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-quoting',
                 options: [
                   Lino::Model::Option.new(
                     '--opt1', 'value1 with spaces', quoting: '"'
                   ),
                   Lino::Model::Option.new(
                     '--opt2', 'value2 with spaces', quoting: '"'
                   )
                 ]
               )))
    end

    it 'uses the specified option quoting character for multiple options ' \
       'when provided' do
      expect(
        described_class
          .for_command('command-with-quoting')
          .with_option_quoting('"')
          .with_options(
            {
              '--opt1' => 'value1 with spaces',
              '--opt2' => 'value2 with spaces'
            }
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-quoting',
                 options: [
                   Lino::Model::Option.new(
                     '--opt1', 'value1 with spaces', quoting: '"'
                   ),
                   Lino::Model::Option.new(
                     '--opt2', 'value2 with spaces', quoting: '"'
                   )
                 ]
               )))
    end

    it 'uses the specified option quoting character for repeated options ' \
       'when provided' do
      expect(
        described_class
          .for_command('command-with-quoting')
          .with_option_quoting('"')
          .with_repeated_option(
            '--opt',
            ['value with spaces', 'another value with spaces']
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-quoting',
                 options: [
                   Lino::Model::Option.new(
                     '--opt', 'value with spaces', quoting: '"'
                   ),
                   Lino::Model::Option.new(
                     '--opt', 'another value with spaces', quoting: '"'
                   )
                 ]
               )))
    end

    it 'allows the option quoting character to be overridden ' \
       'for single options' do
      expect(
        described_class
          .for_command('command-with-overridden-quoting')
          .with_option('--opt1', 'value 1', quoting: '"')
          .with_option('--opt2', 'value 2', quoting: "'")
          .with_option('--opt3', 'value3')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-overridden-quoting',
                 options: [
                   Lino::Model::Option.new('--opt1', 'value 1', quoting: '"'),
                   Lino::Model::Option.new('--opt2', 'value 2', quoting: "'"),
                   Lino::Model::Option.new('--opt3', 'value3')
                 ]
               )))
    end

    it 'allows the option quoting character to be overridden ' \
       'for multiple options' do
      expect(
        described_class
          .for_command('command-with-overridden-quoting')
          .with_options(
            [
              {
                option: '--opt1',
                value: 'value 1',
                quoting: '"'
              },
              {
                option: '--opt2',
                value: 'value 2',
                quoting: "'"
              },
              {
                option: '--opt3',
                value: 'value3'
              }
            ]
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-overridden-quoting',
                 options: [
                   Lino::Model::Option.new(
                     '--opt1', 'value 1', quoting: '"'
                   ),
                   Lino::Model::Option.new(
                     '--opt2', 'value 2', quoting: "'"
                   ),
                   Lino::Model::Option.new('--opt3', 'value3')
                 ]
               )))
    end

    it 'allows the option quoting character to be overridden ' \
       'for repeated options' do
      expect(
        described_class
          .for_command('command-with-overridden-quoting')
          .with_repeated_option(
            '--opt1', %w[val1 val2], quoting: '"'
          )
          .with_repeated_option(
            '--opt2', %w[val3 val4], quoting: "'"
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-overridden-quoting',
                 options: [
                   Lino::Model::Option.new(
                     '--opt1', 'val1', quoting: '"'
                   ),
                   Lino::Model::Option.new(
                     '--opt1', 'val2', quoting: '"'
                   ),
                   Lino::Model::Option.new(
                     '--opt2', 'val3', quoting: "'"
                   ),
                   Lino::Model::Option.new(
                     '--opt2', 'val4', quoting: "'"
                   )
                 ]
               )))
    end

    it 'allows the option quoting character to be overridden ' \
       'for single options on subcommands' do
      builder = described_class
                .for_command('command-with-overridden-quoting')
      builder = builder.with_subcommand('sub') do |sub|
        sub
          .with_option('--opt1', 'value 1', quoting: '"')
          .with_option('--opt2', 'value 2', quoting: "'")
          .with_option('--opt3', 'value3')
      end
      result = builder.build

      expect(result)
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-overridden-quoting',
                 subcommands: [
                   Lino::Model::Subcommand.new(
                     'sub',
                     options: [
                       Lino::Model::Option.new(
                         '--opt1', 'value 1', quoting: '"'
                       ),
                       Lino::Model::Option.new(
                         '--opt2', 'value 2', quoting: "'"
                       ),
                       Lino::Model::Option.new('--opt3', 'value3')
                     ]
                   )
                 ]
               )))
    end

    it 'allows the option quoting character to be overridden ' \
       'for multiple options on subcommands' do
      builder = described_class
                .for_command('command-with-overridden-quoting')
      builder = builder.with_subcommand('sub') do |sub|
        sub
          .with_options(
            [
              { option: '--opt1', value: 'value 1', quoting: '"' },
              { option: '--opt2', value: 'value 2', quoting: "'" },
              { option: '--opt3', value: 'value3' }
            ]
          )
      end
      result = builder.build

      expect(result)
        .to(
          eq(
            Lino::Model::CommandLine.new(
              'command-with-overridden-quoting',
              subcommands: [
                Lino::Model::Subcommand.new(
                  'sub',
                  options: [
                    Lino::Model::Option.new('--opt1', 'value 1', quoting: '"'),
                    Lino::Model::Option.new('--opt2', 'value 2', quoting: "'"),
                    Lino::Model::Option.new('--opt3', 'value3')
                  ]
                )
              ]
            )
          )
        )
    end

    it 'allows the option quoting character to be overridden ' \
       'for repeated options on subcommands' do
      result = described_class
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

      expect(result)
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-overridden-quoting',
                 subcommands: [
                   Lino::Model::Subcommand.new(
                     'sub',
                     options: [
                       Lino::Model::Option.new('--opt1', 'val1', quoting: '"'),
                       Lino::Model::Option.new('--opt1', 'val2', quoting: '"'),
                       Lino::Model::Option.new('--opt2', 'val3', quoting: "'"),
                       Lino::Model::Option.new('--opt2', 'val4', quoting: "'"),
                       Lino::Model::Option.new('--opt3', 'val5'),
                       Lino::Model::Option.new('--opt3', 'val6')
                     ]
                   )
                 ]
               )))
    end

    it 'treats option specific separators as higher precedence than the ' \
       'global option separator for single options' do
      expect(
        described_class
          .for_command('command-with-overridden-separator')
          .with_option_separator('=')
          .with_option('--opt1', 'val1', separator: ':')
          .with_option('--opt2', 'val2', separator: '~')
          .with_option('--opt3', 'val3')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-overridden-separator',
                 options: [
                   Lino::Model::Option.new(
                     '--opt1', 'val1', separator: ':'
                   ),
                   Lino::Model::Option.new(
                     '--opt2', 'val2', separator: '~'
                   ),
                   Lino::Model::Option.new(
                     '--opt3', 'val3', separator: '='
                   )
                 ]
               )))
    end

    it 'treats option specific separators as higher precedence than the ' \
       'global option separator for multiple options' do
      expect(
        described_class
          .for_command('command-with-overridden-separator')
          .with_option_separator('=')
          .with_options(
            [
              {
                option: '--opt1',
                value: 'val1',
                separator: ':'
              },
              {
                option: '--opt2',
                value: 'val2',
                separator: '~'
              },
              {
                option: '--opt3',
                value: 'val3'
              }
            ]
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-overridden-separator',
                 options: [
                   Lino::Model::Option.new(
                     '--opt1', 'val1', separator: ':'
                   ),
                   Lino::Model::Option.new(
                     '--opt2', 'val2', separator: '~'
                   ),
                   Lino::Model::Option.new(
                     '--opt3', 'val3', separator: '='
                   )
                 ]
               )))
    end

    it 'treats option specific separators as higher precedence than ' \
       'the global option separator for repeated options' do
      expect(
        described_class
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
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-overridden-separator',
                 options: [
                   Lino::Model::Option.new('--opt1', 'val1', separator: ':'),
                   Lino::Model::Option.new('--opt1', 'val2', separator: ':'),
                   Lino::Model::Option.new('--opt2', 'val3', separator: '~'),
                   Lino::Model::Option.new('--opt2', 'val4', separator: '~'),
                   Lino::Model::Option.new('--opt3', 'val5', separator: '='),
                   Lino::Model::Option.new('--opt3', 'val6', separator: '=')
                 ]
               )))
    end
  end

  describe 'flags' do
    it 'includes single flags after the command' do
      expect(
        described_class
          .for_command('command-with-flags')
          .with_flag('--verbose')
          .with_flag('-h')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-flags',
                 options: [
                   Lino::Model::Flag.new('--verbose'),
                   Lino::Model::Flag.new('-h')
                 ]
               )))
    end

    it 'includes multiple flags after the command' do
      expect(
        described_class
          .for_command('command-with-flags')
          .with_flags(['--verbose', '-h'])
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-flags',
                 options: [
                   Lino::Model::Flag.new('--verbose'),
                   Lino::Model::Flag.new('-h')
                 ]
               )))
    end

    it 'ignores nil flags when passing a single flag' do
      expect(
        described_class
          .for_command('command-with-flags')
          .with_flag(nil)
          .with_flag('-h')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-flags',
                 options: [
                   Lino::Model::Flag.new('-h')
                 ]
               )))
    end

    it 'ignores nil flags when passing multiple flags' do
      expect(
        described_class
          .for_command('command-with-flags')
          .with_flags(['--verbose', nil, '-h'])
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-flags',
                 options: [
                   Lino::Model::Flag.new('--verbose'),
                   Lino::Model::Flag.new('-h')
                 ]
               )))
    end

    it 'does nothing when nil or empty array provided when ' \
       'passing multiple flags' do
      expect(
        described_class
          .for_command('command-with-flags')
          .with_flags(nil)
          .with_flags([])
          .build
      )
        .to(eq(Lino::Model::CommandLine.new('command-with-flags')))
    end
  end

  describe 'arguments' do
    it 'includes single args after the command and all flags and options' do
      expect(
        described_class
          .for_command('command-with-args')
          .with_flag('-v')
          .with_option('--opt', 'val')
          .with_argument('path/to/file.txt')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-args',
                 options: [
                   Lino::Model::Flag.new('-v'),
                   Lino::Model::Option.new('--opt', 'val')
                 ],
                 arguments: [
                   Lino::Model::Argument.new('path/to/file.txt')
                 ]
               )))
    end

    it 'allows numeric argument' do
      expect(
        described_class
          .for_command('command-with-args')
          .with_argument(10)
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-args',
                 arguments: [
                   Lino::Model::Argument.new(10)
                 ]
               )))
    end

    it 'allows boolean argument' do
      expect(
        described_class
          .for_command('command-with-args')
          .with_argument(true)
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-args',
                 arguments: [
                   Lino::Model::Argument.new(true)
                 ]
               )))
    end

    it 'allows object argument' do
      value = Object.new
      expect(
        described_class
          .for_command('command-with-args')
          .with_argument(value)
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-args',
                 arguments: [
                   Lino::Model::Argument.new(value)
                 ]
               )))
    end

    it 'includes multiple args after the command and all flags and options' do
      expect(
        described_class
          .for_command('command-with-args')
          .with_flag('-v')
          .with_option('--opt', 'val')
          .with_arguments(%w[path/to/file1.txt path/to/file2.txt])
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-args',
                 options: [
                   Lino::Model::Flag.new('-v'),
                   Lino::Model::Option.new('--opt', 'val')
                 ],
                 arguments: [
                   Lino::Model::Argument.new('path/to/file1.txt'),
                   Lino::Model::Argument.new('path/to/file2.txt')
                 ]
               )))
    end

    it 'ignores nil args when passing a single arg' do
      expect(
        described_class
          .for_command('command-with-args')
          .with_flag('-v')
          .with_option('--opt', 'val')
          .with_argument(nil)
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-args',
                 options: [
                   Lino::Model::Flag.new('-v'),
                   Lino::Model::Option.new('--opt', 'val')
                 ]
               )))
    end

    it 'ignores empty args when passing a single arg' do
      expect(
        described_class
          .for_command('command-with-args')
          .with_flag('-v')
          .with_option('--opt', 'val')
          .with_argument('')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-args',
                 options: [
                   Lino::Model::Flag.new('-v'),
                   Lino::Model::Option.new('--opt', 'val')
                 ]
               )))
    end

    it 'ignores nil args when passing multiple args' do
      expect(
        described_class
          .for_command('command-with-args')
          .with_flag('-v')
          .with_option('--opt', 'val')
          .with_arguments(
            [
              'path/to/file1.txt', nil, 'path/to/file2.txt'
            ]
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-args',
                 options: [
                   Lino::Model::Flag.new('-v'),
                   Lino::Model::Option.new('--opt', 'val')
                 ],
                 arguments: [
                   Lino::Model::Argument.new('path/to/file1.txt'),
                   Lino::Model::Argument.new('path/to/file2.txt')
                 ]
               )))
    end

    it 'does nothing when nil or empty arguments provided when ' \
       'passing multiple arguments' do
      expect(
        described_class
          .for_command('command-with-args')
          .with_arguments(nil)
          .with_arguments([])
          .build
      )
        .to(eq(Lino::Model::CommandLine.new('command-with-args')))
    end

    it 'allows single and multiple args to be used together' do
      expect(
        described_class
          .for_command('command-with-args')
          .with_flag('-v')
          .with_option('--opt', 'val')
          .with_arguments(%w[path/to/file1.txt path/to/file2.txt])
          .with_argument('another_file.txt')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-args',
                 options: [
                   Lino::Model::Flag.new('-v'),
                   Lino::Model::Option.new('--opt', 'val')
                 ],
                 arguments: [
                   Lino::Model::Argument.new('path/to/file1.txt'),
                   Lino::Model::Argument.new('path/to/file2.txt'),
                   Lino::Model::Argument.new('another_file.txt')
                 ]
               )))
    end
  end

  describe 'environment variables' do
    it 'includes single environment variables before the command' do
      expect(
        described_class
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
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-environment-variables',
                 environment_variables: [
                   Lino::Model::EnvironmentVariable.new('ENV_VAR1', 'VAL1'),
                   Lino::Model::EnvironmentVariable.new('ENV_VAR2', 'VAL2'),
                   Lino::Model::EnvironmentVariable.new('ENV_VAR3', '"[1,2,3]"')
                 ]
               )))
    end

    it 'includes multiple environment variables passed as a hash ' \
       'before the command' do
      expect(
        described_class
          .for_command('command-with-environment-variables')
          .with_environment_variables(
            {
              'ENV_VAR1' => 'VAL1',
              'ENV_VAR2' => 'VAL2',
              'ENV_VAR3' => '"[1,2,3]"'
            }
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-environment-variables',
                 environment_variables: [
                   Lino::Model::EnvironmentVariable.new('ENV_VAR1', 'VAL1'),
                   Lino::Model::EnvironmentVariable.new('ENV_VAR2', 'VAL2'),
                   Lino::Model::EnvironmentVariable.new('ENV_VAR3', '"[1,2,3]"')
                 ]
               )))
    end

    it 'includes multiple environment variables passed as an array ' \
       'before the command' do
      expect(
        described_class
          .for_command('command-with-environment-variables')
          .with_environment_variables(
            [
              { name: 'ENV_VAR1', value: 'VAL1' },
              { name: 'ENV_VAR2', value: 'VAL2' },
              { name: 'ENV_VAR3', value: '"[1,2,3]"' }
            ]
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-environment-variables',
                 environment_variables: [
                   Lino::Model::EnvironmentVariable.new('ENV_VAR1', 'VAL1'),
                   Lino::Model::EnvironmentVariable.new('ENV_VAR2', 'VAL2'),
                   Lino::Model::EnvironmentVariable.new('ENV_VAR3', '"[1,2,3]"')
                 ]
               )))
    end

    it 'does nothing when nil or empty environment variables provided when ' \
       'passing multiple environment variables' do
      expect(
        described_class
          .for_command('command-with-environment-variables')
          .with_environment_variables(nil)
          .with_environment_variables([])
          .with_environment_variables({})
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-environment-variables'
               )))
    end

    it 'allows single and multiple environment variables to be used together' do
      expect(
        described_class
          .for_command('command-with-environment-variables')
          .with_environment_variable(
            'ENV_VAR1', 'VAL1'
          )
          .with_environment_variables(
            {
              'ENV_VAR2' => 'VAL2',
              'ENV_VAR3' => '"[1,2,3]"'
            }
          )
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-environment-variables',
                 environment_variables: [
                   Lino::Model::EnvironmentVariable.new(
                     'ENV_VAR1', 'VAL1'
                   ),
                   Lino::Model::EnvironmentVariable.new(
                     'ENV_VAR2', 'VAL2'
                   ),
                   Lino::Model::EnvironmentVariable.new(
                     'ENV_VAR3', '"[1,2,3]"'
                   )
                 ]
               )))
    end
  end

  describe 'option placement' do
    it 'includes command options and flags before subcommands by default' do
      expect(
        described_class
          .for_command('command-with-subcommand')
          .with_flag('-v')
          .with_option('--opt', 'val')
          .with_subcommand('sub1')
          .with_subcommand('sub2')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-subcommand',
                 options: [
                   Lino::Model::Flag.new('-v'),
                   Lino::Model::Option.new('--opt', 'val')
                 ],
                 subcommands: [
                   Lino::Model::Subcommand.new('sub1'),
                   Lino::Model::Subcommand.new('sub2')
                 ]
               )))
    end

    it 'includes command options and flags before subcommands when specified' do
      expect(
        described_class
          .for_command('command-with-subcommand')
          .with_options_after_command
          .with_flag('-v')
          .with_option('--opt', 'val')
          .with_subcommand('sub1')
          .with_subcommand('sub2')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-subcommand',
                 options: [
                   Lino::Model::Flag.new(
                     '-v', placement: :after_command
                   ),
                   Lino::Model::Option.new('--opt', 'val',
                                           placement: :after_command)
                 ],
                 subcommands: [
                   Lino::Model::Subcommand.new('sub1'),
                   Lino::Model::Subcommand.new('sub2')
                 ]
               )))
    end

    it 'includes command options and flags after subcommands when specified' do
      expect(
        described_class
          .for_command('command-with-subcommand')
          .with_options_after_subcommands
          .with_flag('-v')
          .with_option('--opt', 'val')
          .with_subcommand('sub1')
          .with_subcommand('sub2')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-subcommand',
                 options: [
                   Lino::Model::Flag.new(
                     '-v', placement: :after_subcommands
                   ),
                   Lino::Model::Option.new(
                     '--opt', 'val', placement: :after_subcommands
                   )
                 ],
                 subcommands: [
                   Lino::Model::Subcommand.new('sub1'),
                   Lino::Model::Subcommand.new('sub2')
                 ]
               )))
    end

    it 'includes command options and flags after arguments when specified' do
      expect(
        described_class
          .for_command('command-with-subcommand')
          .with_options_after_arguments
          .with_flag('-v')
          .with_option('--opt', 'val')
          .with_argument('/some/path.txt')
          .with_subcommand('sub1')
          .with_subcommand('sub2')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-subcommand',
                 options: [
                   Lino::Model::Flag.new(
                     '-v', placement: :after_arguments
                   ),
                   Lino::Model::Option.new(
                     '--opt', 'val', placement: :after_arguments
                   )
                 ],
                 arguments: [
                   Lino::Model::Argument.new('/some/path.txt')
                 ],
                 subcommands: [
                   Lino::Model::Subcommand.new('sub1'),
                   Lino::Model::Subcommand.new('sub2')
                 ]
               )))
    end

    it 'allows option placement to be overridden for single options' do
      expect(
        described_class
          .for_command('command-with-overridden-placement')
          .with_option(
            '--opt1', 'val1', placement: :after_command
          )
          .with_option(
            '--opt2', 'val2', placement: :after_subcommands
          )
          .with_option(
            '--opt3', 'val3', placement: :after_arguments
          )
          .with_subcommands(%w[sub cmd])
          .with_argument('arg')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-overridden-placement',
                 options: [
                   Lino::Model::Option.new(
                     '--opt1', 'val1', placement: :after_command
                   ),
                   Lino::Model::Option.new(
                     '--opt2', 'val2', placement: :after_subcommands
                   ),
                   Lino::Model::Option.new(
                     '--opt3', 'val3', placement: :after_arguments
                   )
                 ],
                 arguments: [
                   Lino::Model::Argument.new('arg')
                 ],
                 subcommands: [
                   Lino::Model::Subcommand.new('sub'),
                   Lino::Model::Subcommand.new('cmd')
                 ]
               )))
    end

    it 'allows option placement to be overridden for multiple options' do
      expect(
        described_class
          .for_command('command-with-overridden-placement')
          .with_options(
            [
              { option: '--opt1', value: 'val1', placement: :after_command },
              { option: '--opt2', value: 'val2',
                placement: :after_subcommands },
              { option: '--opt3', value: 'val3', placement: :after_arguments }
            ]
          )
          .with_subcommands(%w[sub cmd])
          .with_argument('arg')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command-with-overridden-placement',
                 options: [
                   Lino::Model::Option.new(
                     '--opt1', 'val1', placement: :after_command
                   ),
                   Lino::Model::Option.new(
                     '--opt2', 'val2', placement: :after_subcommands
                   ),
                   Lino::Model::Option.new(
                     '--opt3', 'val3', placement: :after_arguments
                   )
                 ],
                 arguments: [
                   Lino::Model::Argument.new('arg')
                 ],
                 subcommands: [
                   Lino::Model::Subcommand.new('sub'),
                   Lino::Model::Subcommand.new('cmd')
                 ]
               )))
    end

    it 'allows option placement to be overridden for repeated options' do
      def option(opt, val, opts)
        Lino::Model::Option.new(opt, val, opts)
      end

      expect(
        described_class
          .for_command('command-with-overridden-placement')
          .with_repeated_option(
            '--opt1', %w[val1 val2], placement: :after_command
          )
          .with_repeated_option(
            '--opt2', %w[val3 val4], placement: :after_subcommands
          )
          .with_repeated_option(
            '--opt3', %w[val5 val6], placement: :after_arguments
          )
          .with_subcommand('sub')
          .with_argument('arg')
          .build
      )
        .to(
          eq(
            Lino::Model::CommandLine.new(
              'command-with-overridden-placement',
              options: [
                option('--opt1', 'val1', placement: :after_command),
                option('--opt1', 'val2', placement: :after_command),
                option('--opt2', 'val3', placement: :after_subcommands),
                option('--opt2', 'val4', placement: :after_subcommands),
                option('--opt3', 'val5', placement: :after_arguments),
                option('--opt3', 'val6', placement: :after_arguments)
              ],
              arguments: [
                Lino::Model::Argument.new('arg')
              ],
              subcommands: [
                Lino::Model::Subcommand.new('sub')
              ]
            )
          )
        )
    end
  end

  describe 'executor' do
    it 'uses the executor from global configuration by default' do
      executor = Lino::Executors::Mock.new

      Lino.configure do |config|
        config.executor = executor
      end

      expect(
        described_class
          .for_command('command')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new('command', executor:)))
    ensure
      Lino.reset!
    end

    it 'uses the supplied executor when provided' do
      expect(
        described_class
          .for_command('command')
          .with_executor(Lino::Executors::Open4.new)
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command',
                 executor: Lino::Executors::Open4.new
               )))
    end
  end

  describe 'working directory' do
    it 'uses a nil working directory by default' do
      expect(
        described_class
          .for_command('command')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new('command', working_directory: nil)))
    end

    it 'uses the supplied working directory when provided' do
      expect(
        described_class
          .for_command('command')
          .with_working_directory('some/path/to/directory')
          .build
      )
        .to(eq(Lino::Model::CommandLine.new(
                 'command',
                 working_directory: 'some/path/to/directory'
               )))
    end
  end
end
