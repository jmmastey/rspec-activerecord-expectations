require "bundler/setup"
require 'pry'
require "rspec/activerecord/expectations"

require_relative "support/activerecord_setup"
require_relative "support/failure_mode"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.filter_run_when_matching :focus

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  include RSpec::ActiveRecord::Expectations
end
