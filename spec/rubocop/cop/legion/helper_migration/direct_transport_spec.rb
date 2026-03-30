# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/helper_migration/direct_transport'

RSpec.describe RuboCop::Cop::Legion::HelperMigration::DirectTransport, :config do
  context 'with Legion::Transport::Connection.session_open?' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::Transport::Connection.session_open?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `transport_session_open?` instead of `Legion::Transport::Connection.session_open?`. Include the transport helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        transport_session_open?
      RUBY
    end
  end

  context 'with Legion::Transport::Connection.channel_open?' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::Transport::Connection.channel_open?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `transport_channel_open?` instead of `Legion::Transport::Connection.channel_open?`. Include the transport helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        transport_channel_open?
      RUBY
    end
  end

  context 'with Legion::Transport::Connection.lite_mode?' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::Transport::Connection.lite_mode?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `transport_lite_mode?` instead of `Legion::Transport::Connection.lite_mode?`. Include the transport helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        transport_lite_mode?
      RUBY
    end
  end

  context 'with Legion::Transport::Connection.channel' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::Transport::Connection.channel
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `transport_channel` instead of `Legion::Transport::Connection.channel`. Include the transport helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        transport_channel
      RUBY
    end
  end

  context 'with Legion::Transport::Spool.count' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::Transport::Spool.count
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `transport_spool_count` instead of `Legion::Transport::Spool.count`. Include the transport helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        transport_spool_count
      RUBY
    end
  end

  context 'when calling methods on other receivers' do
    it 'does not flag transport_session_open? helper' do
      expect_no_offenses('transport_session_open?')
    end

    it 'does not flag Other::Transport::Connection.session_open?' do
      expect_no_offenses('Other::Transport::Connection.session_open?')
    end

    it 'does not flag Legion::Transport::Connection.new' do
      expect_no_offenses('Legion::Transport::Connection.new')
    end
  end
end
