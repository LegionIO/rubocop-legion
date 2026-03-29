# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/helper_migration/direct_cache'

RSpec.describe RuboCop::Cop::Legion::HelperMigration::DirectCache, :config do
  context 'with Legion::Cache.get' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::Cache.get(key)
        ^^^^^^^^^^^^^^^^^^^^^^ Use `cache_get` instead of `Legion::Cache.get`. Include the appropriate cache helper mixin.
      RUBY
    end

    it 'auto-corrects to cache_get' do
      expect_offense(<<~RUBY)
        Legion::Cache.get(key)
        ^^^^^^^^^^^^^^^^^^^^^^ Use `cache_get` instead of `Legion::Cache.get`. Include the appropriate cache helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        cache_get(key)
      RUBY
    end
  end

  context 'with Legion::Cache.set' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::Cache.set(key, value)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `cache_set` instead of `Legion::Cache.set`. Include the appropriate cache helper mixin.
      RUBY
    end

    it 'auto-corrects to cache_set' do
      expect_offense(<<~RUBY)
        Legion::Cache.set(key, value)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `cache_set` instead of `Legion::Cache.set`. Include the appropriate cache helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        cache_set(key, value)
      RUBY
    end
  end

  context 'with Legion::Cache.delete' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::Cache.delete(key)
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `cache_delete` instead of `Legion::Cache.delete`. Include the appropriate cache helper mixin.
      RUBY
    end

    it 'auto-corrects to cache_delete' do
      expect_offense(<<~RUBY)
        Legion::Cache.delete(key)
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `cache_delete` instead of `Legion::Cache.delete`. Include the appropriate cache helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        cache_delete(key)
      RUBY
    end
  end

  it 'does not flag cache_get' do
    expect_no_offenses('cache_get(key)')
  end

  it 'does not flag Legion::Cache::Local.get (handled by DirectLocalCache)' do
    expect_no_offenses('Legion::Cache::Local.get(key)')
  end

  it 'does not flag Other::Cache.get' do
    expect_no_offenses('Other::Cache.get(key)')
  end
end
