# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::SelfContainedActorRunnerClass do
  subject(:cop) { described_class.new }

  context 'when an actor class has `def manual` but no `def runner_class`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Actor
          class Foo
                ^^^ Legion/Extension/SelfContainedActorRunnerClass: Self-contained actors must override `runner_class` to return `self.class`.
            def manual
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when an actor class has `def action` but no `def runner_class`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Actor
          class Bar
                ^^^ Legion/Extension/SelfContainedActorRunnerClass: Self-contained actors must override `runner_class` to return `self.class`.
            def action(args)
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when an actor class has both `def manual` and `def runner_class`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Foo
            def runner_class
              self.class
            end

            def manual
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when an actor class has neither `def manual` nor `def action`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Foo
            def interval
              60
            end
          end
        end
      RUBY
    end
  end

  context 'when a class with `def manual` is outside `Actor` namespace' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def manual
            { success: true }
          end
        end
      RUBY
    end
  end
end
