# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::ActorInheritance do
  subject(:cop) { described_class.new }

  context 'when an actor class has no superclass' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Actor
          class Foo
                ^^^ Legion/Extension/ActorInheritance: Actor must inherit from a recognized base: Every, Once, Poll, Subscription, Loop, or Nothing.
          end
        end
      RUBY
    end
  end

  context 'when an actor class inherits from an unrecognized base' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Actor
          class Foo < SomeOtherBase
                ^^^ Legion/Extension/ActorInheritance: Actor must inherit from a recognized base: Every, Once, Poll, Subscription, Loop, or Nothing.
          end
        end
      RUBY
    end
  end

  context 'when an actor class inherits from Every (short form)' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Foo < Every
          end
        end
      RUBY
    end
  end

  context 'when an actor class inherits from Legion::Extensions::Actors::Every' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Foo < Legion::Extensions::Actors::Every
          end
        end
      RUBY
    end
  end

  context 'when an actor class inherits from Subscription' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Foo < Subscription
          end
        end
      RUBY
    end
  end

  context 'when an actor class inherits from Once' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Foo < Once
          end
        end
      RUBY
    end
  end

  context 'when an actor class inherits from Poll' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Foo < Poll
          end
        end
      RUBY
    end
  end

  context 'when an actor class inherits from Loop' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Foo < Loop
          end
        end
      RUBY
    end
  end

  context 'when an actor class inherits from Nothing' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Foo < Nothing
          end
        end
      RUBY
    end
  end

  context 'when a class is outside the Actor namespace' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Foo
        end
      RUBY
    end
  end
end
