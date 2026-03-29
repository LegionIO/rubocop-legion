# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::SettingsBracketMultiArg do
  subject(:cop) { described_class.new }

  context 'when `Legion::Settings` is accessed with 2 arguments' do
    it 'registers an offense and auto-corrects to `.dig`' do
      expect_offense(<<~RUBY)
        Legion::Settings[:logging, :enabled]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/Extension/SettingsBracketMultiArg: `Legion::Settings#[]` takes exactly 1 argument. Use `Legion::Settings.dig(...)` for nested access.
      RUBY

      expect_correction(<<~RUBY)
        Legion::Settings.dig(:logging, :enabled)
      RUBY
    end
  end

  context 'when `Legion::Settings` is accessed with 3 arguments' do
    it 'registers an offense and auto-corrects to `.dig`' do
      expect_offense(<<~RUBY)
        Legion::Settings[:a, :b, :c]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/Extension/SettingsBracketMultiArg: `Legion::Settings#[]` takes exactly 1 argument. Use `Legion::Settings.dig(...)` for nested access.
      RUBY

      expect_correction(<<~RUBY)
        Legion::Settings.dig(:a, :b, :c)
      RUBY
    end
  end

  context 'when `Legion::Settings` is accessed with 1 argument' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Legion::Settings[:logging]
      RUBY
    end
  end

  context 'when a different hash is accessed with multiple arguments' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        hash[:a, :b]
      RUBY
    end
  end

  context 'when a different constant is accessed with multiple arguments' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        OtherSettings[:a, :b]
      RUBY
    end
  end
end
