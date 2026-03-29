# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::SettingsKeyMethod do
  subject(:cop) { described_class.new }

  context 'when `Legion::Settings.key?` is called' do
    it 'registers an offense and auto-corrects to `!Legion::Settings[...].nil?`' do
      expect_offense(<<~RUBY)
        Legion::Settings.key?(:foo)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/Extension/SettingsKeyMethod: `Legion::Settings` has no `key?` method. Use `!Legion::Settings[:foo].nil?` instead.
      RUBY

      expect_correction(<<~RUBY)
        !Legion::Settings[:foo].nil?
      RUBY
    end
  end

  context 'when bracket access is used' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Legion::Settings[:foo]
      RUBY
    end
  end

  context 'when `key?` is called on a plain hash' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        hash.key?(:foo)
      RUBY
    end
  end

  context 'when `key?` is called on another constant' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        SomeHash.key?(:foo)
      RUBY
    end
  end
end
