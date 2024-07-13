# frozen_string_literal: true

require 'spec_helper'
require 'stringio'
require 'tempfile'

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
          stderr: $stderr,
          cwd: nil
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

      stdin = StringIO.new('hello')
      stdout = Tempfile.new
      stderr = Tempfile.new

      allow(Open4).to(receive(:spawn))

      executor.execute(
        command_line,
        stdin:,
        stdout:,
        stderr:
      )

      expect(Open4).to(
        have_received(:spawn).with(
          { 'ENV_VAR' => 'val' },
          'ls', '-l', '-a',
          stdin: 'hello',
          stdout:,
          stderr:,
          cwd: nil
        )
      )
    end

    it 'passes the working directory when present' do
      command_line = Lino::Model::CommandLine.new(
        'ls',
        working_directory: 'some/path/to/directory'
      )
      executor = described_class.new

      allow(Open4).to(receive(:spawn))

      executor.execute(command_line)

      expect(Open4).to(
        have_received(:spawn).with(
          {},
          'ls',
          stdin: '',
          stdout: $stdout,
          stderr: $stderr,
          cwd: 'some/path/to/directory'
        )
      )
    end
  end

  describe '#==' do
    it 'returns true when class equal' do
      first = described_class.new
      second = described_class.new

      expect(first == second).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(described_class).new
      second = described_class.new

      expect(first == second).to(be(false))
    end
  end

  describe '#eql?' do
    it 'returns true when class equal' do
      first = described_class.new
      second = described_class.new

      expect(first.eql?(second)).to(be(true))
    end

    it 'returns false when class different' do
      first = Class.new(described_class).new
      second = described_class.new

      expect(first.eql?(second)).to(be(false))
    end
  end

  describe '#hash' do
    it 'has same hash when class equal' do
      first = described_class.new
      second = described_class.new

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash when class different' do
      first = Class.new(described_class).new
      second = described_class.new

      expect(first.hash).not_to(eq(second.hash))
    end
  end
end
