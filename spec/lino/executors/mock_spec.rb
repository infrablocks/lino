# frozen_string_literal: true

require 'spec_helper'

describe Lino::Executors::Mock do
  it 'captures single call to execute' do
    command_line = Lino::Model::CommandLine.new(
      'ls',
      options: [
        Lino::Model::Flag.new('-l'),
        Lino::Model::Flag.new('-a')
      ]
    )
    executor = described_class.new

    executor.execute(command_line, some: 'options')

    expect(executor.calls)
      .to(eq(
            [{
              command_line:,
              opts: { some: 'options' },
              exit_code: 0
            }]
          ))
  end

  it 'captures multiple calls to execute' do
    command_line1 = Lino::Model::CommandLine.new(
      'ls',
      options: [
        Lino::Model::Flag.new('-l'),
        Lino::Model::Flag.new('-a')
      ]
    )
    command_line2 = Lino::Model::CommandLine.new('pwd')
    executor = described_class.new

    executor.execute(command_line1, some: 'options')
    executor.execute(command_line2, other: 'options')

    expect(executor.calls)
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
    command_line = Lino::Model::CommandLine.new(
      'ls',
      options: [
        Lino::Model::Flag.new('-l'),
        Lino::Model::Flag.new('-a')
      ]
    )
    executor = described_class.new
    executor.exit_code = 2

    expect { executor.execute(command_line, some: 'options') }
      .to(raise_error(Lino::Errors::ExecutionError))
    expect(executor.calls)
      .to(eq(
            [{
              command_line:,
              opts: { some: 'options' },
              exit_code: 2
            }]
          ))
  end

  it 'resets the mock' do
    command_line1 = Lino::Model::CommandLine.new(
      'ls',
      options: [
        Lino::Model::Flag.new('-l'),
        Lino::Model::Flag.new('-a')
      ]
    )
    command_line2 = Lino::Model::CommandLine.new('pwd')
    executor = described_class.new
    executor.exit_code = 2

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

    expect(executor.calls).to(eq([]))
    expect(executor.exit_code).to(eq(0))
  end
end
