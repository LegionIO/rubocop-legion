# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/llm/settings_access_path'

RSpec.describe RuboCop::Cop::Legion::Llm::SettingsAccessPath, :config do
  it 'registers an offense for two-level loader.settings access' do
    expect_offense(<<~RUBY)
      Legion::Settings.loader.settings[:extensions][:llm]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Legion::Settings.dig(...)` instead of `Legion::Settings.loader.settings[...][...]`.
    RUBY
  end

  it 'registers an offense for assignment via loader.settings' do
    expect_offense(<<~RUBY)
      Legion::Settings.loader.settings[:extensions][:llm] = 'val'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Legion::Settings.dig(...)` instead of `Legion::Settings.loader.settings[...][...]`.
    RUBY
  end

  it 'does not register an offense for Legion::Settings.dig' do
    expect_no_offenses(<<~RUBY)
      Legion::Settings.dig(:extensions, :llm, :default_model)
    RUBY
  end

  it 'does not register an offense for Legion::Settings[:key]' do
    expect_no_offenses(<<~RUBY)
      Legion::Settings[:llm][:default_model]
    RUBY
  end

  it 'does not register an offense for Settings accessed without loader' do
    expect_no_offenses(<<~RUBY)
      settings[:extensions][:llm]
    RUBY
  end
end
