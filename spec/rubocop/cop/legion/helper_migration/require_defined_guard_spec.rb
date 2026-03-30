# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::HelperMigration::RequireDefinedGuard do
  subject(:cop) { described_class.new }

  context 'when require is guarded by defined?(Legion::Transport)' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        require 'legion/transport/message' if defined?(Legion::Transport)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/RequireDefinedGuard: Remove `if defined?(...)` guard from `require`. The framework boot sequence ensures dependencies are loaded.
      RUBY
    end

    it 'auto-corrects by removing the guard' do
      expect_offense(<<~RUBY)
        require 'legion/transport/message' if defined?(Legion::Transport)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/RequireDefinedGuard: Remove `if defined?(...)` guard from `require`. The framework boot sequence ensures dependencies are loaded.
      RUBY

      expect_correction(<<~RUBY)
        require 'legion/transport/message'
      RUBY
    end
  end

  context 'when require_relative is guarded by defined?(Legion::Extensions::Actors::Every)' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        require_relative 'foo/actors/bar' if defined?(Legion::Extensions::Actors::Every)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/RequireDefinedGuard: Remove `if defined?(...)` guard from `require_relative`. The framework boot sequence ensures dependencies are loaded.
      RUBY

      expect_correction(<<~RUBY)
        require_relative 'foo/actors/bar'
      RUBY
    end
  end

  context 'when require is guarded by a compound defined? condition' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        require_relative 'foo' if defined?(Legion::Extensions::Helpers) && Legion::Extensions::Helpers.const_defined?(:Lex)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/RequireDefinedGuard: Remove `if defined?(...)` guard from `require_relative`. The framework boot sequence ensures dependencies are loaded.
      RUBY
    end
  end

  context 'when require has no guard' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        require 'legion/transport/message'
      RUBY
    end
  end

  context 'when require_relative has no guard' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        require_relative 'foo/actors/bar'
      RUBY
    end
  end

  context 'when a non-Legion defined? guard is used' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        require 'json' if defined?(JSON)
      RUBY
    end
  end

  context 'when defined? guards a non-require call' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        puts 'loaded' if defined?(Legion::Transport)
      RUBY
    end
  end
end
