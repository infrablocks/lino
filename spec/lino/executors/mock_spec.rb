# frozen_string_literal: true

require 'spec_helper'

describe Lino::Executors::Mock do
  it 'captures single call to execute' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new

    executor.execute(command_line, some: 'options')

    expect(executor.executions)
      .to(eq(
            [{
              command_line:,
              opts: { some: 'options' },
              exit_code: 0
            }]
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
              {
                command_line: command_line1,
                opts: { some: 'options' },
                exit_code: 0
              },
              {
                command_line: command_line2,
                opts: { other: 'options' },
                exit_code: 0
              }
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
            [{
              command_line:,
              opts: { some: 'options' },
              exit_code: 2
            }]
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

    executor.execute(command_line, stdout: stdout)

    expect(stdout.string).to(eq('Hello!'))
  end

  it 'captures stdout contents on execution when ' \
       'stdout and contents provided' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new
    executor.write_to_stdout('Hello!')

    stdout = StringIO.new

    executor.execute(command_line, stdout: stdout)

    expect(executor.executions)
      .to(eq(
            [{
               command_line:,
               opts: { stdout: stdout },
               exit_code: 0,
               stdout_contents: 'Hello!'
             }]
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
            [{
               command_line:,
               opts: {},
               exit_code: 0
             }]
          ))
  end

  it 'writes to stderr when stderr and contents provided' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new
    executor.write_to_stderr('Error!')

    stderr = StringIO.new

    executor.execute(command_line, stderr: stderr)

    expect(stderr.string).to(eq('Error!'))
  end

  it 'captures stderr contents on execution when ' \
       'stderr and contents provided' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new
    executor.write_to_stderr('Error!')

    stderr = StringIO.new

    executor.execute(command_line, stderr: stderr)

    expect(executor.executions)
      .to(eq(
            [{
               command_line:,
               opts: { stderr: stderr },
               exit_code: 0,
               stderr_contents: 'Error!'
             }]
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
            [{
               command_line:,
               opts: {},
               exit_code: 0
             }]
          ))
  end

  it 'captures contents of stdin on execution when stdin provided' do
    command_line = Lino::Model::CommandLine.new('ls')

    executor = described_class.new
    executor.write_to_stderr('Error!')

    stdin = StringIO.new
    stdin.write('Input!')
    stdin.rewind

    executor.execute(command_line, stdin: stdin)

    expect(executor.executions)
      .to(eq(
            [{
               command_line:,
               opts: { stdin: stdin },
               exit_code: 0,
               stdin_contents: 'Input!'
             }]
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
end
