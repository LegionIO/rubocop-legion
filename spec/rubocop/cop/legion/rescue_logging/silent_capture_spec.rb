# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/rescue_logging/silent_capture'

RSpec.describe RuboCop::Cop::Legion::RescueLogging::SilentCapture, :config do
  context 'when captured variable is never used' do
    it 'registers an offense when body does not reference e' do
      expect_offense(<<~RUBY)
        begin
          risky
        rescue => e
        ^^^^^^^^^^^ Exception captured as `e` but never logged or re-raised. Add `log.error(e.message)` or re-raise.
          puts 'oops'
        end
      RUBY
    end

    it 'registers an offense when body is empty' do
      expect_offense(<<~RUBY)
        begin
          risky
        rescue => e
        ^^^^^^^^^^^ Exception captured as `e` but never logged or re-raised. Add `log.error(e.message)` or re-raise.
        end
      RUBY
    end

    it 'registers an offense when only unrelated variables are used' do
      expect_offense(<<~RUBY)
        begin
          risky
        rescue => e
        ^^^^^^^^^^^ Exception captured as `e` but never logged or re-raised. Add `log.error(e.message)` or re-raise.
          x = 1
          puts x
        end
      RUBY
    end
  end

  context 'when captured variable is used' do
    it 'does not register an offense when e.message is logged' do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue => e
          log.error(e.message)
        end
      RUBY
    end

    it 'does not register an offense when e is passed to a method' do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue => e
          handle_error(e)
        end
      RUBY
    end

    it 'does not register an offense when e is inspected' do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue => e
          puts e.inspect
        end
      RUBY
    end
  end

  context 'when rescue body contains raise' do
    it 'does not register an offense for bare raise' do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue => e
          raise
        end
      RUBY
    end

    it 'does not register an offense for raise e' do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue => e
          raise e
        end
      RUBY
    end

    it 'does not register an offense for raise with a new exception' do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue => e
          raise RuntimeError, e.message
        end
      RUBY
    end
  end

  context 'when rescue has no variable capture' do
    it 'does not register an offense for rescue with no capture' do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue
          nil
        end
      RUBY
    end

    it 'does not register an offense for rescue StandardError with no capture' do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue StandardError
          nil
        end
      RUBY
    end
  end
end
