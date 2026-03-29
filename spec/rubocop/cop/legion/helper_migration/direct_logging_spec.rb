# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/helper_migration/direct_logging'

RSpec.describe RuboCop::Cop::Legion::HelperMigration::DirectLogging, :config do
  %i[info warn error debug fatal].each do |method|
    context "with Legion::Logging.#{method}" do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Legion::Logging.#{method}(msg)
          #{'^' * "Legion::Logging.#{method}(msg)".length} Use `log.#{method}(msg)` instead of `Legion::Logging.#{method}`. Include `Helpers::Lex` or `Legion::Logging::Helper`.
        RUBY
      end

      it "auto-corrects to log.#{method}" do
        expect_offense(<<~RUBY)
          Legion::Logging.#{method}(msg)
          #{'^' * "Legion::Logging.#{method}(msg)".length} Use `log.#{method}(msg)` instead of `Legion::Logging.#{method}`. Include `Helpers::Lex` or `Legion::Logging::Helper`.
        RUBY

        expect_correction(<<~RUBY)
          log.#{method}(msg)
        RUBY
      end
    end
  end

  it 'does not flag log.info' do
    expect_no_offenses('log.info(msg)')
  end

  it 'does not flag a plain string literal' do
    expect_no_offenses('"hello"')
  end

  it 'does not flag Other::Logging.info' do
    expect_no_offenses('Other::Logging.info(msg)')
  end

  context 'with multiple arguments' do
    it 'preserves all arguments in the correction' do
      expect_offense(<<~RUBY)
        Legion::Logging.info('hello', key: 'val')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `log.info(msg)` instead of `Legion::Logging.info`. Include `Helpers::Lex` or `Legion::Logging::Helper`.
      RUBY

      expect_correction(<<~RUBY)
        log.info('hello', key: 'val')
      RUBY
    end
  end
end
