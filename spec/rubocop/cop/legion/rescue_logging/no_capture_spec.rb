# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/rescue_logging/no_capture'

RSpec.describe RuboCop::Cop::Legion::RescueLogging::NoCapture, :config do
  context 'when exception class is specified but not captured' do
    it 'registers an offense for rescue StandardError' do
      expect_offense(<<~RUBY)
        begin
          risky
        rescue StandardError
        ^^^^^^^^^^^^^^^^^^^^ Exception class specified but not captured. Use `rescue StandardError => e` and log the exception.
          nil
        end
      RUBY
    end

    it 'registers an offense for rescue ArgumentError, TypeError' do
      expect_offense(<<~RUBY)
        begin
          risky
        rescue ArgumentError, TypeError
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Exception class specified but not captured. Use `rescue ArgumentError, TypeError => e` and log the exception.
          nil
        end
      RUBY
    end

    it 'registers an offense for rescue RuntimeError in a method' do
      expect_offense(<<~RUBY)
        def foo
          risky
        rescue RuntimeError
        ^^^^^^^^^^^^^^^^^^^ Exception class specified but not captured. Use `rescue RuntimeError => e` and log the exception.
          false
        end
      RUBY
    end
  end

  context 'when exception is captured' do
    it 'does not register an offense for rescue StandardError => e' do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue StandardError => e
          log.error(e.message)
        end
      RUBY
    end

    it 'does not register an offense for rescue ArgumentError, TypeError => e' do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue ArgumentError, TypeError => e
          log.error(e.message)
        end
      RUBY
    end
  end

  context 'when bare rescue with no class and no capture' do
    it 'does not register an offense (handled by BareRescue cop)' do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue
          nil
        end
      RUBY
    end
  end

  context 'when rescue modifier' do
    it 'does not register an offense for inline rescue' do
      expect_no_offenses(<<~RUBY)
        foo rescue StandardError
      RUBY
    end
  end
end
