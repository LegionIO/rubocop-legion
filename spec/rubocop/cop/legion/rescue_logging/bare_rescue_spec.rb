# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/rescue_logging/bare_rescue'

RSpec.describe RuboCop::Cop::Legion::RescueLogging::BareRescue, :config do
  context 'when rescue has no exception class and no variable capture' do
    it 'registers an offense for bare rescue in a begin/end block' do
      expect_offense(<<~RUBY)
        begin
          risky
        rescue
        ^^^^^^ Bare `rescue` swallows all StandardError silently. Capture the exception with `rescue => e` and log it.
          nil
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          risky
        rescue => e
          nil
        end
      RUBY
    end

    it 'registers an offense for bare rescue in a method body' do
      expect_offense(<<~RUBY)
        def foo
          risky
        rescue
        ^^^^^^ Bare `rescue` swallows all StandardError silently. Capture the exception with `rescue => e` and log it.
          false
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          risky
        rescue => e
          false
        end
      RUBY
    end
  end

  context 'when rescue captures the exception variable' do
    it 'does not register an offense for rescue => e' do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue => e
          log.error(e.message)
        end
      RUBY
    end
  end

  context 'when rescue specifies an exception class' do
    it 'does not register an offense for rescue StandardError' do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue StandardError
          nil
        end
      RUBY
    end

    it 'does not register an offense for rescue StandardError => e' do
      expect_no_offenses(<<~RUBY)
        begin
          risky
        rescue StandardError => e
          log.error(e.message)
        end
      RUBY
    end
  end

  context 'when rescue modifier (inline rescue)' do
    it 'does not register an offense for inline rescue nil' do
      expect_no_offenses(<<~RUBY)
        foo rescue nil
      RUBY
    end

    it 'does not register an offense for inline rescue with assignment' do
      expect_no_offenses(<<~RUBY)
        result = risky_call rescue default_value
      RUBY
    end
  end
end
