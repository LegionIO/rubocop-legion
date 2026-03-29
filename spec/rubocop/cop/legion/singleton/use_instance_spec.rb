# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/singleton/use_instance'

RSpec.describe RuboCop::Cop::Legion::Singleton::UseInstance, :config do
  context 'when calling .new on a singleton class' do
    it 'registers an offense for TokenCache.new' do
      expect_offense(<<~RUBY)
        TokenCache.new
        ^^^^^^^^^^^^^^ Use `TokenCache.instance` instead of `.new` for singleton classes.
      RUBY

      expect_correction(<<~RUBY)
        TokenCache.instance
      RUBY
    end

    it 'registers an offense for Registry.new' do
      expect_offense(<<~RUBY)
        Registry.new
        ^^^^^^^^^^^^ Use `Registry.instance` instead of `.new` for singleton classes.
      RUBY

      expect_correction(<<~RUBY)
        Registry.instance
      RUBY
    end

    it 'registers an offense for Catalog.new' do
      expect_offense(<<~RUBY)
        Catalog.new
        ^^^^^^^^^^^ Use `Catalog.instance` instead of `.new` for singleton classes.
      RUBY

      expect_correction(<<~RUBY)
        Catalog.instance
      RUBY
    end

    it 'registers an offense and drops arguments' do
      expect_offense(<<~RUBY)
        TokenCache.new(arg1, arg2)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `TokenCache.instance` instead of `.new` for singleton classes.
      RUBY

      expect_correction(<<~RUBY)
        TokenCache.instance
      RUBY
    end
  end

  context 'when calling .new on a non-singleton class' do
    it 'does not register an offense for SomeOther.new' do
      expect_no_offenses(<<~RUBY)
        SomeOther.new
      RUBY
    end

    it 'does not register an offense for String.new' do
      expect_no_offenses(<<~RUBY)
        String.new
      RUBY
    end
  end

  context 'when already using .instance' do
    it 'does not register an offense for TokenCache.instance' do
      expect_no_offenses(<<~RUBY)
        TokenCache.instance
      RUBY
    end

    it 'does not register an offense for Registry.instance' do
      expect_no_offenses(<<~RUBY)
        Registry.instance
      RUBY
    end
  end
end
