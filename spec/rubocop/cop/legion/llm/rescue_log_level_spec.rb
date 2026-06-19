# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/llm/rescue_log_level'

RSpec.describe RuboCop::Cop::Legion::Llm::RescueLogLevel, :config do
  it 'registers an offense for handle_exception with level: :debug in rescue' do
    expect_offense(<<~RUBY)
      begin
        risky_call
      rescue StandardError => e
        handle_exception(e, level: :debug, operation: 'foo')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `handle_exception` called with `level: :debug` in a rescue. Minimum log level for exceptions is `:warn`.
      end
    RUBY
  end

  it 'does not register an offense for handle_exception with level: :warn' do
    expect_no_offenses(<<~RUBY)
      begin
        risky_call
      rescue StandardError => e
        handle_exception(e, level: :warn, operation: 'foo')
      end
    RUBY
  end

  it 'does not register an offense for handle_exception with level: :error' do
    expect_no_offenses(<<~RUBY)
      begin
        risky_call
      rescue StandardError => e
        handle_exception(e, level: :error, operation: 'foo')
      end
    RUBY
  end

  it 'does not register an offense for handle_exception outside a rescue' do
    expect_no_offenses(<<~RUBY)
      handle_exception(some_error, level: :debug, operation: 'test')
    RUBY
  end
end
