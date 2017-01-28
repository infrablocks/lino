require 'spec_helper'

RSpec.describe Lino::CommandLineBuilder do
  it 'includes the provided command in the resulting command line' do
    command_line = Lino::CommandLineBuilder
        .for_command('ls')
        .build

    expect(command_line.to_s).to eq('ls')
  end
end
