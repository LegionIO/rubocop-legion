# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/constant_safety/inherit_param'

RSpec.describe RuboCop::Cop::Legion::ConstantSafety::InheritParam, :config do
  context 'const_defined? with one argument' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        mod.const_defined?('Foo')
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Pass `false` as inherit parameter: `const_defined?('Foo', false)`. Default `true` leaks through `Object`.
      RUBY
    end

    it 'auto-corrects by adding , false' do
      expect_offense(<<~RUBY)
        mod.const_defined?('Foo')
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Pass `false` as inherit parameter: `const_defined?('Foo', false)`. Default `true` leaks through `Object`.
      RUBY

      expect_correction(<<~RUBY)
        mod.const_defined?('Foo', false)
      RUBY
    end

    it 'registers an offense with a symbol argument' do
      expect_offense(<<~RUBY)
        mod.const_defined?(:Foo)
        ^^^^^^^^^^^^^^^^^^^^^^^^ Pass `false` as inherit parameter: `const_defined?(:Foo, false)`. Default `true` leaks through `Object`.
      RUBY
    end

    it 'registers an offense when called on self' do
      expect_offense(<<~RUBY)
        self.const_defined?('Foo')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Pass `false` as inherit parameter: `const_defined?('Foo', false)`. Default `true` leaks through `Object`.
      RUBY
    end
  end

  context 'const_defined? with two arguments' do
    it 'does not register an offense when false is passed' do
      expect_no_offenses(<<~RUBY)
        mod.const_defined?('Foo', false)
      RUBY
    end

    it 'does not register an offense when true is passed' do
      expect_no_offenses(<<~RUBY)
        mod.const_defined?('Foo', true)
      RUBY
    end
  end

  context 'const_get with one argument' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        mod.const_get('Bar')
        ^^^^^^^^^^^^^^^^^^^^ Pass `false` as inherit parameter: `const_get('Bar', false)`. Default `true` leaks through `Object`.
      RUBY
    end

    it 'auto-corrects by adding , false' do
      expect_offense(<<~RUBY)
        mod.const_get('Bar')
        ^^^^^^^^^^^^^^^^^^^^ Pass `false` as inherit parameter: `const_get('Bar', false)`. Default `true` leaks through `Object`.
      RUBY

      expect_correction(<<~RUBY)
        mod.const_get('Bar', false)
      RUBY
    end

    it 'registers an offense with a symbol argument' do
      expect_offense(<<~RUBY)
        mod.const_get(:Bar)
        ^^^^^^^^^^^^^^^^^^^ Pass `false` as inherit parameter: `const_get(:Bar, false)`. Default `true` leaks through `Object`.
      RUBY
    end
  end

  context 'const_get with two arguments' do
    it 'does not register an offense when false is passed' do
      expect_no_offenses(<<~RUBY)
        mod.const_get('Bar', false)
      RUBY
    end

    it 'does not register an offense when true is passed' do
      expect_no_offenses(<<~RUBY)
        mod.const_get('Bar', true)
      RUBY
    end
  end

  context 'inside Legion namespace' do
    it 'still registers an offense for const_defined? with one arg' do
      expect_offense(<<~RUBY)
        module Legion
          mod.const_defined?('Foo')
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Pass `false` as inherit parameter: `const_defined?('Foo', false)`. Default `true` leaks through `Object`.
        end
      RUBY
    end

    it 'does not register an offense when false is already passed' do
      expect_no_offenses(<<~RUBY)
        module Legion
          mod.const_defined?('Foo', false)
        end
      RUBY
    end
  end
end
