# frozen_string_literal: true

require 'open4'
require 'stringio'
require 'spec_helper'

describe Lino::CommandLine do
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
        'ls', '-la',
        stdin: stdin,
        stdout: stdout,
        stderr: stderr
      )
    )
  end
end
