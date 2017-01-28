require 'open4'
require 'spec_helper'

describe Lino::CommandLine do
  it 'executes the command line with an empty stdin and default stdout and stderr when not provided' do
    command = 'ls -la'
    command_line = Lino::CommandLine.new(command)

    expect(Open4).to(
        receive(:spawn).with(command, stdin: '', stdout: STDOUT, stderr: STDERR))

    command_line.execute
  end
end
