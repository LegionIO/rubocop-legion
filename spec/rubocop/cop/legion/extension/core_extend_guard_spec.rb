# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::CoreExtendGuard do
  subject(:cop) { described_class.new }

  context 'when `extend Legion::Extensions::Core` has no guard' do
    it 'registers an offense and auto-corrects to add the guard' do
      expect_offense(<<~RUBY)
        extend Legion::Extensions::Core
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/Extension/CoreExtendGuard: Guard `extend Core` with `if Legion::Extensions.const_defined?(:Core)` for standalone test compatibility.
      RUBY

      expect_correction(<<~RUBY)
        extend Legion::Extensions::Core if Legion::Extensions.const_defined?(:Core)
      RUBY
    end
  end

  context 'when `extend Legion::Extensions::Core` already has the const_defined? guard' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        extend Legion::Extensions::Core if Legion::Extensions.const_defined?(:Core)
      RUBY
    end
  end

  context 'when `extend SomethingElse` is called' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        extend SomethingElse
      RUBY
    end
  end

  context 'when extending a partial Legion constant' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        extend Legion::Extensions::Helpers::Lex
      RUBY
    end
  end
end
