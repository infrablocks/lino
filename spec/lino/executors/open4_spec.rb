# frozen_string_literal: true

require 'spec_helper'

describe Lino::Executors::Open4 do
  describe '#execute' do
    it 'executes the command line with an empty stdin and default ' \
       'stdout and stderr when not provided' do
      command_line = Lino::Model::CommandLine.new(
        'ls',
        options: [
          Lino::Model::Flag.new('-l'),
          Lino::Model::Flag.new('-a')
        ],
        environment_variables: [
          Lino::Model::EnvironmentVariable.new('ENV_VAR', 'val')
        ]
      )
      executor = described_class.new

      allow(Open4).to(receive(:spawn))

      executor.execute(command_line)

      expect(Open4).to(
        have_received(:spawn).with(
          { 'ENV_VAR' => 'val' },
          'ls', '-l', '-a',
          stdin: '',
          stdout: $stdout,
          stderr: $stderr
        )
      )
    end

    it 'uses the supplied stdin, stdout and stderr when provided' do
      command_line = Lino::Model::CommandLine.new(
        'ls',
        options: [
          Lino::Model::Flag.new('-l'),
          Lino::Model::Flag.new('-a')
        ],
        environment_variables: [
          Lino::Model::EnvironmentVariable.new('ENV_VAR', 'val')
        ]
      )
      executor = described_class.new

      stdin = 'hello'
      stdout = StringIO.new
      stderr = StringIO.new

      allow(Open4).to(receive(:spawn))

      executor.execute(
        command_line,
        stdin: stdin,
        stdout: stdout,
        stderr: stderr
      )

      expect(Open4).to(
        have_received(:spawn).with(
          { 'ENV_VAR' => 'val' },
          'ls', '-l', '-a',
          stdin: stdin,
          stdout: stdout,
          stderr: stderr
        )
      )
    end
  end
end
