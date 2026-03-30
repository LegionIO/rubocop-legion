# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::DefinitionCallMismatched do
  subject(:cop) { described_class.new }

  context 'when `definition :foo` has no matching `def foo`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Runners
          module Foo
            definition :do_work
            ^^^^^^^^^^^^^^^^^^^ Legion/Extension/DefinitionCallMismatched: `definition :do_work` has no matching `def do_work` method.
          end
        end
      RUBY
    end
  end

  context 'when `definition :foo` has a matching `def foo`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Runners
          module Foo
            definition :do_work

            def do_work
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when multiple definitions all have matching methods' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Runners
          module Foo
            definition :create
            definition :update
            definition :delete

            def create
              { success: true }
            end

            def update
              { success: true }
            end

            def delete
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when one of multiple definitions is missing its method' do
    it 'registers an offense for the missing one' do
      expect_offense(<<~RUBY)
        module Runners
          module Foo
            definition :create
            definition :update
            ^^^^^^^^^^^^^^^^^^ Legion/Extension/DefinitionCallMismatched: `definition :update` has no matching `def update` method.

            def create
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when definition is inside a class (not just modules)' do
    it 'registers an offense when method is missing' do
      expect_offense(<<~RUBY)
        class Foo
          definition :do_work
          ^^^^^^^^^^^^^^^^^^^ Legion/Extension/DefinitionCallMismatched: `definition :do_work` has no matching `def do_work` method.
        end
      RUBY
    end
  end

  context 'when definition is called with a non-symbol argument' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Runners
          module Foo
            definition 'do_work'
          end
        end
      RUBY
    end
  end
end
