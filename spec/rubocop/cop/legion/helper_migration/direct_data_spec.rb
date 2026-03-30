# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::HelperMigration::DirectData do
  subject(:cop) { described_class.new }

  context 'with Legion::Data::Connection.sequel' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::Data::Connection.sequel
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DirectData: Use `data_connection` instead of `Legion::Data::Connection.sequel`. Include `Legion::Data::Helper` via the data helper mixin.
      RUBY
    end

    it 'auto-corrects to data_connection' do
      expect_offense(<<~RUBY)
        Legion::Data::Connection.sequel
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DirectData: Use `data_connection` instead of `Legion::Data::Connection.sequel`. Include `Legion::Data::Helper` via the data helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        data_connection
      RUBY
    end
  end

  context 'with Legion::Data::Local.connected?' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::Data::Local.connected?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DirectData: Use `local_data_connected?` instead of `Legion::Data::Local.connected?`. Include `Legion::Data::Helper` via the data helper mixin.
      RUBY
    end

    it 'auto-corrects to local_data_connected?' do
      expect_offense(<<~RUBY)
        Legion::Data::Local.connected?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DirectData: Use `local_data_connected?` instead of `Legion::Data::Local.connected?`. Include `Legion::Data::Helper` via the data helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        local_data_connected?
      RUBY
    end
  end

  context 'with Legion::Data::Local.connection' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::Data::Local.connection
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DirectData: Use `local_data_connection` instead of `Legion::Data::Local.connection`. Include `Legion::Data::Helper` via the data helper mixin.
      RUBY
    end

    it 'auto-corrects to local_data_connection' do
      expect_offense(<<~RUBY)
        Legion::Data::Local.connection
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DirectData: Use `local_data_connection` instead of `Legion::Data::Local.connection`. Include `Legion::Data::Helper` via the data helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        local_data_connection
      RUBY
    end
  end

  context 'with Legion::Data::Local.model' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::Data::Local.model(:traces)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DirectData: Use `local_data_model` instead of `Legion::Data::Local.model`. Include `Legion::Data::Helper` via the data helper mixin.
      RUBY
    end

    it 'auto-corrects to local_data_model with arguments' do
      expect_offense(<<~RUBY)
        Legion::Data::Local.model(:traces)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DirectData: Use `local_data_model` instead of `Legion::Data::Local.model`. Include `Legion::Data::Helper` via the data helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        local_data_model(:traces)
      RUBY
    end
  end

  context 'when calling unrelated methods' do
    it 'does not flag Legion::Data::Connection.setup' do
      expect_no_offenses(<<~RUBY)
        Legion::Data::Connection.setup
      RUBY
    end

    it 'does not flag Legion::Data::Local.setup' do
      expect_no_offenses(<<~RUBY)
        Legion::Data::Local.setup
      RUBY
    end

    it 'does not flag data_connection helper' do
      expect_no_offenses(<<~RUBY)
        data_connection
      RUBY
    end

    it 'does not flag local_data_model helper' do
      expect_no_offenses(<<~RUBY)
        local_data_model(:traces)
      RUBY
    end
  end
end
