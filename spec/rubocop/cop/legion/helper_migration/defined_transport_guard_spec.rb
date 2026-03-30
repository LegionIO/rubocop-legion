# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::HelperMigration::DefinedTransportGuard do
  subject(:cop) { described_class.new }

  context 'when defined?(Legion::Transport) is used as a condition' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        return unless defined?(Legion::Transport)
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DefinedTransportGuard: Use `transport_connected?` instead of `defined?(Legion::Transport)`. Include `Legion::Transport::Helper` via the transport helper mixin.
      RUBY
    end
  end

  context 'when defined?(Legion::Transport) is used in an if statement' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if defined?(Legion::Transport)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DefinedTransportGuard: Use `transport_connected?` instead of `defined?(Legion::Transport)`. Include `Legion::Transport::Helper` via the transport helper mixin.
          publish_message
        end
      RUBY
    end
  end

  context 'when defined?(Legion::Transport) is used in a compound condition' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if defined?(Legion::Transport) && Legion::Transport.connected?
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DefinedTransportGuard: Use `transport_connected?` instead of `defined?(Legion::Transport)`. Include `Legion::Transport::Helper` via the transport helper mixin.
          publish_message
        end
      RUBY
    end
  end

  context 'when transport_connected? is used' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        return unless transport_connected?
      RUBY
    end
  end

  context 'when defined? is used on a different constant' do
    it 'does not flag defined?(Legion::Cache)' do
      expect_no_offenses(<<~RUBY)
        return unless defined?(Legion::Cache)
      RUBY
    end

    it 'does not flag defined?(SomeOther)' do
      expect_no_offenses(<<~RUBY)
        return unless defined?(SomeOther)
      RUBY
    end
  end

  context 'when defined? is used on a sub-constant of Transport' do
    it 'does not flag defined?(Legion::Transport::Message)' do
      expect_no_offenses(<<~RUBY)
        if defined?(Legion::Transport::Message)
          use_it
        end
      RUBY
    end
  end
end
