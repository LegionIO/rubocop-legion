# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::EveryActorRequiresTime do
  subject(:cop) { described_class.new }

  context 'when an Every actor does not call `time`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Actor
          class Foo < Every
                ^^^ Legion/Extension/EveryActorRequiresTime: Every/Poll actors must call the `time` DSL method to set the interval.
            def manual
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when a Poll actor does not call `time`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Actor
          class Foo < Legion::Extensions::Actors::Poll
                ^^^ Legion/Extension/EveryActorRequiresTime: Every/Poll actors must call the `time` DSL method to set the interval.
            def manual
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when an Every actor calls `time`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Foo < Every
            time 60

            def manual
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when a Poll actor calls `time`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Foo < Legion::Extensions::Actors::Poll
            time 30

            def manual
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when an actor inherits from Subscription (no time needed)' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Foo < Subscription
            def action(payload)
              process(payload)
            end
          end
        end
      RUBY
    end
  end

  context 'when an actor inherits from Once (no time needed)' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Foo < Once
            def manual
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when a class is outside the Actor namespace' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Foo < Every
        end
      RUBY
    end
  end
end
