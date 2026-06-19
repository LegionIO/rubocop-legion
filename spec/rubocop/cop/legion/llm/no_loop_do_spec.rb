# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/llm/no_loop_do'

RSpec.describe RuboCop::Cop::Legion::Llm::NoLoopDo, :config do
  it 'registers an offense for `loop do`' do
    expect_offense(<<~RUBY)
      loop do
      ^^^^ `loop do` is prohibited — use bounded iteration (`N.times`, `each`, or `while` with an explicit decrement) instead.
        attempt_dispatch
        break if done?
      end
    RUBY
  end

  it 'does not register an offense for `MAX.times do`' do
    expect_no_offenses(<<~RUBY)
      MAX_ATTEMPTS.times do
        attempt_dispatch
        break if done?
      end
    RUBY
  end

  it 'does not register an offense for `while` with condition' do
    expect_no_offenses(<<~RUBY)
      i = 0
      while i < 5
        i += 1
      end
    RUBY
  end

  it 'does not register an offense for `items.each`' do
    expect_no_offenses(<<~RUBY)
      items.each { |item| process(item) }
    RUBY
  end
end
