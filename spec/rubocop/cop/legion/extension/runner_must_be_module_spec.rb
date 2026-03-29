# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::RunnerMustBeModule do
  subject(:cop) { described_class.new }

  context 'when a class is defined inside `Runners`' do
    it 'registers an offense on the class name' do
      expect_offense(<<~RUBY)
        module Runners
          class Foo
                ^^^ Legion/Extension/RunnerMustBeModule: Runners must be modules, not classes. Use `module` for runner definitions.
          end
        end
      RUBY
    end
  end

  context 'when a class is nested deeply inside `Runners`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module MyExtension
          module Runners
            class Bar
                  ^^^ Legion/Extension/RunnerMustBeModule: Runners must be modules, not classes. Use `module` for runner definitions.
            end
          end
        end
      RUBY
    end
  end

  context 'when a module is defined inside `Runners`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Runners
          module Foo
          end
        end
      RUBY
    end
  end

  context 'when a class is defined outside `Runners`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Foo
        end
      RUBY
    end
  end

  context 'when a class is inside a different named module' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Foo
          end
        end
      RUBY
    end
  end
end
