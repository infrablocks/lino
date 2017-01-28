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

  it 'includes flags after the command' do
    command_line = Lino::CommandLineBuilder
        .for_command('command-with-flags')
        .with_flag('--verbose')
        .with_flag('-h')
        .build

    expect(command_line.to_s).to eq('command-with-flags --verbose -h')
  end
end
