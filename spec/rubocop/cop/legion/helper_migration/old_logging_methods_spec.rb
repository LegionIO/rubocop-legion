# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/helper_migration/old_logging_methods'

RSpec.describe RuboCop::Cop::Legion::HelperMigration::OldLoggingMethods, :config do
  {
    log_info: 'info',
    log_warn: 'warn',
    log_error: 'error',
    log_debug: 'debug',
    log_fatal: 'fatal'
  }.each do |old_method, new_method|
    context "with #{old_method}" do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          #{old_method}(msg)
          #{'^' * "#{old_method}(msg)".length} Use `log.#{new_method}(msg)` instead of `#{old_method}`. Include `Helpers::Lex` or `Legion::Logging::Helper`.
        RUBY
      end

      it "auto-corrects to log.#{new_method}" do
        expect_offense(<<~RUBY)
          #{old_method}(msg)
          #{'^' * "#{old_method}(msg)".length} Use `log.#{new_method}(msg)` instead of `#{old_method}`. Include `Helpers::Lex` or `Legion::Logging::Helper`.
        RUBY

        expect_correction(<<~RUBY)
          log.#{new_method}(msg)
        RUBY
      end
    end
  end

  it 'does not flag log.info' do
    expect_no_offenses('log.info(msg)')
  end

  it 'does not flag Legion::Logging.info (handled by DirectLogging cop)' do
    expect_no_offenses('Legion::Logging.info(msg)')
  end

  context 'with multiple arguments' do
    it 'preserves all arguments in the correction' do
      expect_offense(<<~RUBY)
        log_info('hello', key: 'val')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `log.info(msg)` instead of `log_info`. Include `Helpers::Lex` or `Legion::Logging::Helper`.
      RUBY

      expect_correction(<<~RUBY)
        log.info('hello', key: 'val')
      RUBY
    end
  end
end
