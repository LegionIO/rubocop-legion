# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/framework/no_inline_setting_defaults'

# rubocop:disable Lint/ConstantDefinitionInBlock
RSpec.describe RuboCop::Cop::Legion::Framework::NoInlineSettingDefaults, :config do
  MSG_OR = 'Inline default `%<default>s` after `Legion::Settings` read. ' \
           'Move the default into `settings.rb` instead.'
  MSG_SHADOW = 'Shadow-default pattern after `Legion::Settings` read. ' \
               'Move the default into `settings.rb` instead.'

  MSG_3 = format(MSG_OR, default: '3')
  MSG_CLAUDE = format(MSG_OR, default: '"claude-sonnet"')
  MSG_07 = format(MSG_OR, default: '0.7')
  MSG_30 = format(MSG_OR, default: '30')

  context 'inline || literal fallback' do
    # offense: col=14, len=41
    it 'registers an offense for Settings[:key] || integer' do
      expect_offense(<<~RUBY)
                max_retries = Legion::Settings[:llm][:max_retries] || 3
        #{' ' * 22}#{'^' * 41} #{MSG_3}
      RUBY
    end

    # offense: col=8, len=49
    it 'registers an offense for Settings[:key] || string' do
      expect_offense(<<~RUBY)
                model = Legion::Settings[:llm][:model] || "claude-sonnet"
        #{' ' * 16}#{'^' * 49} #{MSG_CLAUDE}
      RUBY
    end

    # offense: col=7, len=37
    it 'registers an offense for Settings[:key] || float' do
      expect_offense(<<~RUBY)
                temp = Legion::Settings[:temperature] || 0.7
        #{' ' * 15}#{'^' * 37} #{MSG_07}
      RUBY
    end

    # offense: col=10, len=32
    it 'registers an offense for single-level Settings access' do
      expect_offense(<<~RUBY)
                timeout = Legion::Settings[:timeout] || 30
        #{' ' * 18}#{'^' * 32} #{MSG_30}
      RUBY
    end
  end

  context 'shadow-default pattern' do
    # offense: line=2, col=0, len=46
    it 'registers an offense for unless positive?' do
      expect_offense(<<~RUBY)
        max_retries = Legion::Settings[:llm][:max_retries]
        max_retries = 200 unless max_retries.positive?
        #{'^' * 46} #{MSG_SHADOW}
      RUBY
    end

    # offense: line=2, col=8, len=46
    it 'registers an offense for unless nil?' do
      expect_offense(<<~RUBY)
        timeout = Legion::Settings[:timeout]
        timeout = 30 unless timeout.nil?
        #{'^' * 32} #{MSG_SHADOW}
      RUBY
    end
  end

  context 'acceptable patterns' do
    it 'does not register an offense for Settings read without fallback' do
      expect_no_offenses(<<~RUBY)
        max_retries = Legion::Settings[:llm][:max_retries]
      RUBY
    end

    it 'does not register an offense for || between two Settings reads' do
      expect_no_offenses(<<~RUBY)
        val = Legion::Settings[:a] || Legion::Settings[:b]
      RUBY
    end

    it 'does not register an offense for || nil' do
      expect_no_offenses(<<~RUBY)
        val = Legion::Settings[:key] || nil
      RUBY
    end

    it 'does not register an offense for non-Settings || literal' do
      expect_no_offenses(<<~RUBY)
        val = config[:key] || 3
      RUBY
    end

    it 'does not register an offense for shadow-default on non-Settings variable' do
      expect_no_offenses(<<~RUBY)
        count = fetch_count
        count = 10 unless count.positive?
      RUBY
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock
end
