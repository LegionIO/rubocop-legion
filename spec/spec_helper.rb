# frozen_string_literal: true

require 'rubocop'
require 'rubocop/rspec/support'
require 'rubocop-legion'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random
end
