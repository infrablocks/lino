# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lino do
  it 'has a version number' do
    expect(Lino::VERSION).not_to be_nil
  end

  describe 'configuration' do
    before do
      described_class.reset!
    end

    it 'allows default executor to be overridden' do
      executor = Lino::Executors::Open4.new

      described_class.configure do |config|
        config.executor = executor
      end

      expect(described_class.configuration.executor)
        .to(eq(executor))
    end
  end

  describe 'builder_for_command' do
    it 'creates a command line builder for the provided command' do
      expect(described_class.builder_for_command('ls'))
        .to(be_instance_of(Lino::Builders::CommandLine))
    end
  end
end
