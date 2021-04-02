# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  minimum_coverage line: 100, branch: 100
end

require 'bundler/setup'
require 'lino'

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = '.rspec_status'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
