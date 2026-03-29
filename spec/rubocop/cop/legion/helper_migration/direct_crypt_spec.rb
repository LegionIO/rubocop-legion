# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/helper_migration/direct_crypt'

RSpec.describe RuboCop::Cop::Legion::HelperMigration::DirectCrypt, :config do
  context 'with Legion::Crypt.get' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::Crypt.get(path)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `vault_get` instead of `Legion::Crypt.get`. Include the appropriate Vault/Crypt helper mixin.
      RUBY
    end

    it 'auto-corrects to vault_get' do
      expect_offense(<<~RUBY)
        Legion::Crypt.get(path)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `vault_get` instead of `Legion::Crypt.get`. Include the appropriate Vault/Crypt helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        vault_get(path)
      RUBY
    end
  end

  context 'with Legion::Crypt.exist?' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::Crypt.exist?(path)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `vault_exist?` instead of `Legion::Crypt.exist?`. Include the appropriate Vault/Crypt helper mixin.
      RUBY
    end

    it 'auto-corrects to vault_exist?' do
      expect_offense(<<~RUBY)
        Legion::Crypt.exist?(path)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `vault_exist?` instead of `Legion::Crypt.exist?`. Include the appropriate Vault/Crypt helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        vault_exist?(path)
      RUBY
    end
  end

  it 'does not flag vault_get' do
    expect_no_offenses('vault_get(path)')
  end

  it 'does not flag vault_exist?' do
    expect_no_offenses('vault_exist?(path)')
  end

  it 'does not flag Other::Crypt.get' do
    expect_no_offenses('Other::Crypt.get(path)')
  end

  it 'does not flag Legion::Crypt.new' do
    expect_no_offenses('Legion::Crypt.new')
  end

  context 'with a string path argument' do
    it 'preserves the argument in the correction for get' do
      expect_offense(<<~RUBY)
        Legion::Crypt.get('secret/data/mykey')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `vault_get` instead of `Legion::Crypt.get`. Include the appropriate Vault/Crypt helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        vault_get('secret/data/mykey')
      RUBY
    end
  end
end
