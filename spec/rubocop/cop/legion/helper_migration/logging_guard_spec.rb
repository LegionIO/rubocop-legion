# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/helper_migration/logging_guard'

RSpec.describe RuboCop::Cop::Legion::HelperMigration::LoggingGuard, :config do
  context 'with respond_to? for old logging methods' do
    it 'registers an offense for respond_to?(:log_warn, true)' do
      expect_offense(<<~RUBY)
        log.warn(msg) if respond_to?(:log_warn, true)
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `respond_to?(:log_warn)` guard is unnecessary. `log` is always available via `Helpers::Lex`.
      RUBY
    end

    it 'registers an offense for respond_to?(:log_info)' do
      expect_offense(<<~RUBY)
        respond_to?(:log_info) && log.info(msg)
        ^^^^^^^^^^^^^^^^^^^^^^ `respond_to?(:log_info)` guard is unnecessary. `log` is always available via `Helpers::Lex`.
      RUBY
    end

    it 'registers an offense for respond_to?(:log_error)' do
      expect_offense(<<~RUBY)
        if respond_to?(:log_error)
           ^^^^^^^^^^^^^^^^^^^^^^^ `respond_to?(:log_error)` guard is unnecessary. `log` is always available via `Helpers::Lex`.
          log.error(msg)
        end
      RUBY
    end

    it 'registers an offense for respond_to?(:log_debug)' do
      expect_offense(<<~RUBY)
        respond_to?(:log_debug)
        ^^^^^^^^^^^^^^^^^^^^^^^ `respond_to?(:log_debug)` guard is unnecessary. `log` is always available via `Helpers::Lex`.
      RUBY
    end

    it 'registers an offense for respond_to?(:log_fatal)' do
      expect_offense(<<~RUBY)
        respond_to?(:log_fatal)
        ^^^^^^^^^^^^^^^^^^^^^^^ `respond_to?(:log_fatal)` guard is unnecessary. `log` is always available via `Helpers::Lex`.
      RUBY
    end

    it 'registers an offense for respond_to?(:log)' do
      expect_offense(<<~RUBY)
        respond_to?(:log)
        ^^^^^^^^^^^^^^^^^ `respond_to?(:log)` guard is unnecessary. `log` is always available via `Helpers::Lex`.
      RUBY
    end
  end

  context 'with respond_to? for unrelated methods' do
    it 'does not register an offense for respond_to?(:to_s)' do
      expect_no_offenses(<<~RUBY)
        respond_to?(:to_s)
      RUBY
    end

    it 'does not register an offense for respond_to?(:cache_get)' do
      expect_no_offenses(<<~RUBY)
        respond_to?(:cache_get)
      RUBY
    end

    it 'does not register an offense for respond_to?(:run)' do
      expect_no_offenses(<<~RUBY)
        respond_to?(:run)
      RUBY
    end
  end

  context 'with defined?(Legion::Logging)' do
    it 'registers an offense for defined?(Legion::Logging)' do
      expect_offense(<<~RUBY)
        if defined?(Legion::Logging)
           ^^^^^^^^^^^^^^^^^^^^^^^^^ `defined?(Legion::Logging)` guard is unnecessary. `Legion::Logging` is always loaded in the framework.
          Legion::Logging.info(msg)
        end
      RUBY
    end

    it 'registers an offense for inline defined? guard' do
      expect_offense(<<~RUBY)
        Legion::Logging.warn(msg) if defined?(Legion::Logging)
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^ `defined?(Legion::Logging)` guard is unnecessary. `Legion::Logging` is always loaded in the framework.
      RUBY
    end
  end

  context 'with defined? for other constants' do
    it 'does not register an offense for defined?(Legion::Cache)' do
      expect_no_offenses(<<~RUBY)
        defined?(Legion::Cache)
      RUBY
    end

    it 'does not register an offense for defined?(SomeOther)' do
      expect_no_offenses(<<~RUBY)
        defined?(SomeOther)
      RUBY
    end
  end
end
