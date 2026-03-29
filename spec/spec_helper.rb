# frozen_string_literal: true

require 'rubocop'
require 'rubocop/rspec/expect_offense'
require 'rubocop-legion'

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense
  config.disable_monkey_patching!
  config.order = :random
end
