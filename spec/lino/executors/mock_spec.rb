# frozen_string_literal: true

require 'spec_helper'

describe Lino::Executors::Mock do
  it 'captures single call to execute' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new

    executor.execute(command_line, some: 'options')

    expect(executor.executions)
      .to(eq(
            [
              Lino::Executors::Mock::Execution.new(
                command_line:,
                opts: { some: 'options' },
                exit_code: 0
              )
            ]
          ))
  end

  it 'captures multiple calls to execute' do
    command_line1 = Lino::Model::CommandLine.new('ls')
    command_line2 = Lino::Model::CommandLine.new('pwd')

    executor = described_class.new

    executor.execute(command_line1, some: 'options')
    executor.execute(command_line2, other: 'options')

    expect(executor.executions)
      .to(eq(
            [
              Lino::Executors::Mock::Execution.new(
                command_line: command_line1,
                opts: { some: 'options' },
                exit_code: 0
              ),
              Lino::Executors::Mock::Execution.new(
                command_line: command_line2,
                opts: { other: 'options' },
                exit_code: 0
              )
            ]
          ))
  end

  it 'throws when exit code is non-zero' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new
    executor.exit_code = 2

    expect { executor.execute(command_line, some: 'options') }
      .to(raise_error(Lino::Errors::ExecutionError))
    expect(executor.executions)
      .to(eq(
            [
              Lino::Executors::Mock::Execution.new(
                command_line:,
                opts: { some: 'options' },
                exit_code: 2
              )
            ]
          ))
  end

  it 'fails executions when requested' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new
    executor.fail_all_executions

    expect { executor.execute(command_line, some: 'options') }
      .to(raise_error(Lino::Errors::ExecutionError))
    expect { executor.execute(command_line, other: 'options') }
      .to(raise_error(Lino::Errors::ExecutionError))
  end

  it 'writes to stdout when stdout and contents provided' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new
    executor.write_to_stdout('Hello!')

    stdout = StringIO.new

    executor.execute(command_line, stdout:)

    expect(stdout.string).to(eq('Hello!'))
  end

  it 'captures stdout contents on execution when ' \
     'stdout and contents provided' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new
    executor.write_to_stdout('Hello!')

    stdout = StringIO.new

    executor.execute(command_line, stdout:)

    expect(executor.executions)
      .to(eq(
            [
              Lino::Executors::Mock::Execution.new(
                command_line:,
                opts: { stdout: },
                exit_code: 0,
                stdout_contents: 'Hello!'
              )
            ]
          ))
  end

  it 'does not capture stdout contents on execution when ' \
     'stdout not provided' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new
    executor.write_to_stdout('Hello!')

    executor.execute(command_line)

    expect(executor.executions)
      .to(eq(
            [
              Lino::Executors::Mock::Execution.new(
                command_line:,
                opts: {},
                exit_code: 0
              )
            ]
          ))
  end

  it 'writes to stderr when stderr and contents provided' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new
    executor.write_to_stderr('Error!')

    stderr = StringIO.new

    executor.execute(command_line, stderr:)

    expect(stderr.string).to(eq('Error!'))
  end

  it 'captures stderr contents on execution when ' \
     'stderr and contents provided' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new
    executor.write_to_stderr('Error!')

    stderr = StringIO.new

    executor.execute(command_line, stderr:)

    expect(executor.executions)
      .to(eq(
            [
              Lino::Executors::Mock::Execution.new(
                command_line:,
                opts: { stderr: },
                exit_code: 0,
                stderr_contents: 'Error!'
              )
            ]
          ))
  end

  it 'does not capture stderr contents on execution when ' \
     'stderr not provided' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new
    executor.write_to_stderr('Error!')

    executor.execute(command_line)

    expect(executor.executions)
      .to(eq(
            [
              Lino::Executors::Mock::Execution.new(
                command_line:,
                opts: {},
                exit_code: 0
              )
            ]
          ))
  end

  it 'captures contents of stdin on execution when stdin provided' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new
    executor.write_to_stderr('Error!')

    stdin = StringIO.new
    stdin.write('Input!')
    stdin.rewind

    executor.execute(command_line, stdin:)

    expect(executor.executions)
      .to(eq(
            [
              Lino::Executors::Mock::Execution.new(
                command_line:,
                opts: { stdin: },
                exit_code: 0,
                stdin_contents: 'Input!'
              )
            ]
          ))
  end

  it 'resets the mock' do
    command_line1 = Lino::Model::CommandLine.new('ls')
    command_line2 = Lino::Model::CommandLine.new('pwd')

    executor = described_class.new
    executor.exit_code = 2
    executor.write_to_stdout('Hello!')
    executor.write_to_stderr('Error!')

    begin
      executor.execute(command_line1, some: 'options')
    rescue Lino::Errors::ExecutionError
      # no-op
    end
    begin
      executor.execute(command_line2, other: 'options')
    rescue Lino::Errors::ExecutionError
      # no-op
    end

    executor.reset

    expect(executor.executions).to(eq([]))
    expect(executor.exit_code).to(eq(0))
    expect(executor.stdout_contents).to(be_nil)
    expect(executor.stderr_contents).to(be_nil)
  end

  describe Lino::Executors::Mock::Execution do
    describe '#==' do
      let(:state) do
        {
          command_line: Lino::Model::CommandLine.new('ls'),
          opts: {},
          exit_code: 0,
          stdin_contents: 'Input!',
          stdout_contents: 'Hello!',
          stderr_contents: 'Error!'
        }
      end

      it 'returns true when class and state equal' do
        first = described_class.new(state)
        second = described_class.new(state)

        expect(first == second).to(be(true))
      end

      it 'returns false when class different' do
        first = Class.new(described_class).new(state)
        second = described_class.new(state)

        expect(first == second).to(be(false))
      end

      it 'returns false when command line different' do
        first = described_class.new(
          state.merge(command_line: Lino::Model::CommandLine.new('ls'))
        )
        second = described_class.new(
          state.merge(command_line: Lino::Model::CommandLine.new('pwd'))
        )

        expect(first == second).to(be(false))
      end

      it 'returns false when opts different' do
        first = described_class.new(
          state.merge(opts: { some: 'options' })
        )
        second = described_class.new(
          state.merge(opts: { other: 'options' })
        )

        expect(first == second).to(be(false))
      end

      it 'returns false when exit code different' do
        first = described_class.new(
          state.merge(exit_code: 0)
        )
        second = described_class.new(
          state.merge(exit_code: 1)
        )

        expect(first == second).to(be(false))
      end

      it 'returns false when stdin contents different' do
        first = described_class.new(
          state.merge(stdin_contents: 'contents 1')
        )
        second = described_class.new(
          state.merge(stdin_contents: 'contents 2')
        )

        expect(first == second).to(be(false))
      end

      it 'returns false when stdout contents different' do
        first = described_class.new(
          state.merge(stdout_contents: 'contents 1')
        )
        second = described_class.new(
          state.merge(stdout_contents: 'contents 2')
        )

        expect(first == second).to(be(false))
      end

      it 'returns false when stderr contents different' do
        first = described_class.new(
          state.merge(stderr_contents: 'contents 1')
        )
        second = described_class.new(
          state.merge(stderr_contents: 'contents 2')
        )

        expect(first == second).to(be(false))
      end
    end

    describe '#eql?' do
      let(:state) do
        {
          command_line: Lino::Model::CommandLine.new('ls'),
          opts: {},
          exit_code: 0,
          stdin_contents: 'Input!',
          stdout_contents: 'Hello!',
          stderr_contents: 'Error!'
        }
      end

      it 'returns true when class and state equal' do
        first = described_class.new(state)
        second = described_class.new(state)

        expect(first.eql?(second)).to(be(true))
      end

      it 'returns false when class different' do
        first = Class.new(described_class).new(state)
        second = described_class.new(state)

        expect(first.eql?(second)).to(be(false))
      end

      it 'returns false when command line different' do
        first = described_class.new(
          state.merge(command_line: Lino::Model::CommandLine.new('ls'))
        )
        second = described_class.new(
          state.merge(command_line: Lino::Model::CommandLine.new('pwd'))
        )

        expect(first.eql?(second)).to(be(false))
      end

      it 'returns false when opts different' do
        first = described_class.new(
          state.merge(opts: { some: 'options' })
        )
        second = described_class.new(
          state.merge(opts: { other: 'options' })
        )

        expect(first.eql?(second)).to(be(false))
      end

      it 'returns false when exit code different' do
        first = described_class.new(
          state.merge(exit_code: 0)
        )
        second = described_class.new(
          state.merge(exit_code: 1)
        )

        expect(first.eql?(second)).to(be(false))
      end

      it 'returns false when stdin contents different' do
        first = described_class.new(
          state.merge(stdin_contents: 'contents 1')
        )
        second = described_class.new(
          state.merge(stdin_contents: 'contents 2')
        )

        expect(first.eql?(second)).to(be(false))
      end

      it 'returns false when stdout contents different' do
        first = described_class.new(
          state.merge(stdout_contents: 'contents 1')
        )
        second = described_class.new(
          state.merge(stdout_contents: 'contents 2')
        )

        expect(first.eql?(second)).to(be(false))
      end

      it 'returns false when stderr contents different' do
        first = described_class.new(
          state.merge(stderr_contents: 'contents 1')
        )
        second = described_class.new(
          state.merge(stderr_contents: 'contents 2')
        )

        expect(first.eql?(second)).to(be(false))
      end
    end

    describe '#hash' do
      let(:state) do
        {
          command_line: Lino::Model::CommandLine.new('ls'),
          opts: {},
          exit_code: 0,
          stdin_contents: 'Input!',
          stdout_contents: 'Hello!',
          stderr_contents: 'Error!'
        }
      end

      it 'has same hash when class and state equal' do
        first = described_class.new(state)
        second = described_class.new(state)

        expect(first.hash).to(eq(second.hash))
      end

      it 'has different hash when class different' do
        first = Class.new(described_class).new(state)
        second = described_class.new(state)

        expect(first.hash).not_to(eq(second.hash))
      end

      it 'has different hash when command line different' do
        first = described_class.new(
          state.merge(command_line: Lino::Model::CommandLine.new('ls'))
        )
        second = described_class.new(
          state.merge(command_line: Lino::Model::CommandLine.new('pwd'))
        )

        expect(first.hash).not_to(eq(second.hash))
      end

      it 'has different hash when opts different' do
        first = described_class.new(
          state.merge(opts: { some: 'options' })
        )
        second = described_class.new(
          state.merge(opts: { other: 'options' })
        )

        expect(first.hash).not_to(eq(second.hash))
      end

      it 'has different hash when exit code different' do
        first = described_class.new(
          state.merge(exit_code: 0)
        )
        second = described_class.new(
          state.merge(exit_code: 1)
        )

        expect(first.hash).not_to(eq(second.hash))
      end

      it 'has different hash when stdin contents different' do
        first = described_class.new(
          state.merge(stdin_contents: 'contents 1')
        )
        second = described_class.new(
          state.merge(stdin_contents: 'contents 2')
        )

        expect(first.hash).not_to(eq(second.hash))
      end

      it 'has different hash when stdout contents different' do
        first = described_class.new(
          state.merge(stdout_contents: 'contents 1')
        )
        second = described_class.new(
          state.merge(stdout_contents: 'contents 2')
        )

        expect(first.hash).not_to(eq(second.hash))
      end

      it 'has different hash when stderr contents different' do
        first = described_class.new(
          state.merge(stderr_contents: 'contents 1')
        )
        second = described_class.new(
          state.merge(stderr_contents: 'contents 2')
        )

        expect(first.hash).not_to(eq(second.hash))
      end
    end
  end
end
