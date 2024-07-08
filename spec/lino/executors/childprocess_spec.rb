# frozen_string_literal: true

require 'spec_helper'

describe Lino::Executors::Childprocess do
  describe '#execute' do
    it 'executes the command line with inherited streams by default' do
      command_line = Lino::Model::CommandLine.new(
        'ls',
        options: [
          Lino::Model::Flag.new('-l'),
          Lino::Model::Flag.new('-a')
        ]
      )
      executor = described_class.new

      child_process = instance_double(ChildProcess::AbstractProcess)
      io = instance_double(ChildProcess::AbstractIO)
      allow(ChildProcess).to(receive(:build)).and_return(child_process)
      allow(child_process).to(receive(:io)).and_return(io)
      allow(child_process).to(receive(:cwd=))
      allow(child_process).to(receive(:start))
      allow(child_process).to(receive(:wait).and_return(0))
      allow(io).to(receive(:inherit!))

      executor.execute(command_line)

      expect(ChildProcess)
        .to(have_received(:build).with('ls', '-l', '-a').ordered)
      expect(io).to(have_received(:inherit!).ordered)
      expect(child_process).to(have_received(:start).ordered)
      expect(child_process).to(have_received(:wait).ordered)
    end

    it 'uses the working directory supplied in the command line' do
      command_line = Lino::Model::CommandLine.new(
        'ls',
        working_directory: 'some/path/to/directory'
      )
      executor = described_class.new

      child_process = instance_double(ChildProcess::AbstractProcess)
      io = instance_double(ChildProcess::AbstractIO)
      allow(ChildProcess).to(receive(:build)).and_return(child_process)
      allow(child_process).to(receive(:io)).and_return(io)
      allow(child_process).to(receive(:cwd=))
      allow(child_process).to(receive(:start))
      allow(child_process).to(receive(:wait).and_return(0))
      allow(io).to(receive(:inherit!))

      executor.execute(command_line)

      expect(ChildProcess)
        .to(have_received(:build).with('ls').ordered)
      expect(io).to(have_received(:inherit!).ordered)
      expect(child_process)
        .to(have_received(:cwd=)
              .with('some/path/to/directory').ordered)
      expect(child_process).to(have_received(:start).ordered)
      expect(child_process).to(have_received(:wait).ordered)
    end

    it 'uses the environment supplied in the command line' do
      command_line = Lino::Model::CommandLine.new(
        'ls',
        environment_variables: [
          Lino::Model::EnvironmentVariable.new('ENV_VAR1', 'val1'),
          Lino::Model::EnvironmentVariable.new('ENV_VAR2', 'val2')
        ]
      )
      executor = described_class.new

      child_process = instance_double(ChildProcess::AbstractProcess)
      io = instance_double(ChildProcess::AbstractIO)
      environment = instance_double(Hash)
      allow(ChildProcess).to(receive(:build)).and_return(child_process)
      allow(child_process).to(receive(:io)).and_return(io)
      allow(child_process).to(receive(:cwd=))
      allow(child_process).to(receive(:start))
      allow(child_process).to(receive_messages(environment:,
                                               wait: 0))
      allow(io).to(receive(:inherit!))
      allow(environment).to(receive(:[]=))

      executor.execute(command_line)

      expect(ChildProcess)
        .to(have_received(:build).with('ls').ordered)
      expect(io).to(have_received(:inherit!).ordered)
      expect(environment)
        .to(have_received(:[]=)
              .with('ENV_VAR1', 'val1').ordered)
      expect(environment)
        .to(have_received(:[]=)
              .with('ENV_VAR2', 'val2').ordered)
      expect(child_process).to(have_received(:start).ordered)
      expect(child_process).to(have_received(:wait).ordered)
    end

    it 'uses the supplied stdout and stderr when provided' do
      command_line = Lino::Model::CommandLine.new('ls')
      executor = described_class.new

      stdout = StringIO.new
      stderr = StringIO.new

      child_process = instance_double(ChildProcess::AbstractProcess)
      io = instance_double(ChildProcess::AbstractIO)
      allow(ChildProcess).to(receive(:build)).and_return(child_process)
      allow(child_process).to(receive(:io)).and_return(io)
      allow(child_process).to(receive(:cwd=))
      allow(child_process).to(receive(:start))
      allow(child_process).to(receive(:wait).and_return(0))
      allow(io).to(receive(:inherit!))
      allow(io).to(receive(:stdout=))
      allow(io).to(receive(:stderr=))

      executor.execute(command_line, stdout:, stderr:)

      expect(ChildProcess)
        .to(have_received(:build).with('ls').ordered)
      expect(io).to(have_received(:inherit!).ordered)
      expect(io).to(have_received(:stdout=).with(stdout).ordered)
      expect(io).to(have_received(:stderr=).with(stderr).ordered)
      expect(child_process).to(have_received(:start).ordered)
      expect(child_process).to(have_received(:wait).ordered)
    end

    it 'writes contents of provided stdin to stdin on the ' \
         'IO of the process and closes it' do
      command_line = Lino::Model::CommandLine.new('ls')
      executor = described_class.new

      input = StringIO.new('hello')

      child_process = instance_double(ChildProcess::AbstractProcess)
      io = instance_double(ChildProcess::AbstractIO)
      stdin = instance_double(IO)
      allow(ChildProcess).to(receive(:build)).and_return(child_process)
      allow(child_process).to(receive(:io)).and_return(io)
      allow(child_process).to(receive(:cwd=))
      allow(child_process).to(receive(:duplex=))
      allow(child_process).to(receive(:start))
      allow(child_process).to(receive(:wait).and_return(0))
      allow(io).to(receive(:inherit!))
      allow(io).to(receive(:stdin)).and_return(stdin)
      allow(stdin).to(receive(:write))
      allow(stdin).to(receive(:close))

      executor.execute(command_line, stdin: input)

      expect(ChildProcess)
        .to(have_received(:build).with('ls').ordered)
      expect(io).to(have_received(:inherit!).ordered)
      expect(child_process).to(have_received(:duplex=).with(true).ordered)
      expect(child_process).to(have_received(:start).ordered)
      expect(stdin).to(have_received(:write).with('hello').ordered)
      expect(stdin).to(have_received(:close).ordered)
      expect(child_process).to(have_received(:wait).ordered)
    end

    it 'raises an error if the exit code is not zero' do
      command_line = Lino::Model::CommandLine.new('ls')
      executor = described_class.new

      child_process = instance_double(ChildProcess::AbstractProcess)
      io = instance_double(ChildProcess::AbstractIO)
      allow(ChildProcess).to(receive(:build)).and_return(child_process)
      allow(child_process).to(receive(:io)).and_return(io)
      allow(child_process).to(receive(:cwd=))
      allow(child_process).to(receive(:start))
      allow(child_process).to(receive(:wait).and_return(2))
      allow(io).to(receive(:inherit!))

      expect { executor.execute(command_line) }
        .to(raise_error(Lino::Errors::ExecutionError))
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
