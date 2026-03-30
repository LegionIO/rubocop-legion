# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/helper_migration/direct_json'

RSpec.describe RuboCop::Cop::Legion::HelperMigration::DirectJson, :config do
  context 'with Legion::JSON.load' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::JSON.load(str)
        ^^^^^^^^^^^^^^^^^^^^^^ Use `json_load` instead of `Legion::JSON.load`. Include the appropriate JSON helper mixin.
      RUBY
    end

    it 'auto-corrects to json_load' do
      expect_offense(<<~RUBY)
        Legion::JSON.load(str)
        ^^^^^^^^^^^^^^^^^^^^^^ Use `json_load` instead of `Legion::JSON.load`. Include the appropriate JSON helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        json_load(str)
      RUBY
    end
  end

  context 'with Legion::JSON.dump' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::JSON.dump(obj)
        ^^^^^^^^^^^^^^^^^^^^^^ Use `json_dump` instead of `Legion::JSON.dump`. Include the appropriate JSON helper mixin.
      RUBY
    end

    it 'auto-corrects to json_dump' do
      expect_offense(<<~RUBY)
        Legion::JSON.dump(obj)
        ^^^^^^^^^^^^^^^^^^^^^^ Use `json_dump` instead of `Legion::JSON.dump`. Include the appropriate JSON helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        json_dump(obj)
      RUBY
    end
  end

  context 'with Legion::JSON.parse' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::JSON.parse(str)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `json_parse` instead of `Legion::JSON.parse`. Include the appropriate JSON helper mixin.
      RUBY
    end

    it 'auto-corrects to json_parse' do
      expect_offense(<<~RUBY)
        Legion::JSON.parse(str)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `json_parse` instead of `Legion::JSON.parse`. Include the appropriate JSON helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        json_parse(str)
      RUBY
    end
  end

  context 'with Legion::JSON.generate' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::JSON.generate(obj)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `json_generate` instead of `Legion::JSON.generate`. Include the appropriate JSON helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        json_generate(obj)
      RUBY
    end
  end

  context 'with Legion::JSON.pretty_generate' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::JSON.pretty_generate(obj)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `json_pretty_generate` instead of `Legion::JSON.pretty_generate`. Include the appropriate JSON helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        json_pretty_generate(obj)
      RUBY
    end
  end

  it 'does not flag json_load' do
    expect_no_offenses('json_load(str)')
  end

  it 'does not flag json_dump' do
    expect_no_offenses('json_dump(obj)')
  end

  it 'does not flag Other::JSON.load' do
    expect_no_offenses('Other::JSON.load(str)')
  end

  it 'does not flag ::JSON.load' do
    expect_no_offenses('::JSON.load(str)')
  end

  context 'with multiple arguments' do
    it 'preserves all arguments in the correction for dump' do
      expect_offense(<<~RUBY)
        Legion::JSON.dump(obj, pretty: true)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `json_dump` instead of `Legion::JSON.dump`. Include the appropriate JSON helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        json_dump(obj, pretty: true)
      RUBY
    end
  end
end
