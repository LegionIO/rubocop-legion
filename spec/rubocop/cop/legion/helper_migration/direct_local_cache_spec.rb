# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/helper_migration/direct_local_cache'

RSpec.describe RuboCop::Cop::Legion::HelperMigration::DirectLocalCache, :config do
  context 'with Legion::Cache::Local.get' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::Cache::Local.get(key)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `local_cache_get` instead of `Legion::Cache::Local.get`. Include the appropriate local cache helper mixin.
      RUBY
    end

    it 'auto-corrects to local_cache_get' do
      expect_offense(<<~RUBY)
        Legion::Cache::Local.get(key)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `local_cache_get` instead of `Legion::Cache::Local.get`. Include the appropriate local cache helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        local_cache_get(key)
      RUBY
    end
  end

  context 'with Legion::Cache::Local.set' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::Cache::Local.set(key, value)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `local_cache_set` instead of `Legion::Cache::Local.set`. Include the appropriate local cache helper mixin.
      RUBY
    end

    it 'auto-corrects to local_cache_set' do
      expect_offense(<<~RUBY)
        Legion::Cache::Local.set(key, value)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `local_cache_set` instead of `Legion::Cache::Local.set`. Include the appropriate local cache helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        local_cache_set(key, value)
      RUBY
    end
  end

  context 'with Legion::Cache::Local.delete' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::Cache::Local.delete(key)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `local_cache_delete` instead of `Legion::Cache::Local.delete`. Include the appropriate local cache helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        local_cache_delete(key)
      RUBY
    end
  end

  context 'with Legion::Cache::Local.fetch' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::Cache::Local.fetch(key) { compute }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `local_cache_fetch` instead of `Legion::Cache::Local.fetch`. Include the appropriate local cache helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        local_cache_fetch(key) { compute }
      RUBY
    end
  end

  it 'does not flag local_cache_get' do
    expect_no_offenses('local_cache_get(key)')
  end

  it 'does not flag Legion::Cache.get (handled by DirectCache)' do
    expect_no_offenses('Legion::Cache.get(key)')
  end

  it 'does not flag Other::Cache::Local.get' do
    expect_no_offenses('Other::Cache::Local.get(key)')
  end
end
