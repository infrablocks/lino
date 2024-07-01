# frozen_string_literal: true

if `uname` =~ /Darwin/
  notification(
    :terminal_notifier,
    app_name: 'lino ::',
    activate: 'com.googlecode.iTerm2'
  )
end

guard(
  :rspec,
  cmd: 'bundle exec rspec',
  all_after_pass: true,
  all_on_start: true
) do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Bubble up if no spec found
  rspec.spec = lambda { |m|
    spec_file = Guard::RSpec::Dsl.detect_spec_file_for(rspec, m)
    spec_file = File.dirname(spec_file) until File.exist?(spec_file)
    spec_file
  }
end
