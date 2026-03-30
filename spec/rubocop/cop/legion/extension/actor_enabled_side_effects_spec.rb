# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::ActorEnabledSideEffects do
  subject(:cop) { described_class.new }

  context 'when `def enabled?` is inside an Actor namespace' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Actor
          class Check < Every
            def enabled?
            ^^^^^^^^^^^^ Legion/Extension/ActorEnabledSideEffects: `enabled?` runs during extension loading, before `delay`. Keep it cheap and side-effect-free (no network calls, mutex locks, or I/O).
              Legion::Transport.connected?
            end
          end
        end
      RUBY
    end
  end

  context 'when `def enabled?` is nested deeply inside Actor namespace' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Legion
          module Extensions
            module Foo
              module Actor
                class Bar < Once
                  def enabled?
                  ^^^^^^^^^^^^ Legion/Extension/ActorEnabledSideEffects: `enabled?` runs during extension loading, before `delay`. Keep it cheap and side-effect-free (no network calls, mutex locks, or I/O).
                    true
                  end
                end
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when `def enabled?` is outside Actor namespace' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Runners
          module Check
            def enabled?
              true
            end
          end
        end
      RUBY
    end
  end

  context 'when a different method is defined inside Actor namespace' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actor
          class Check < Every
            def run
              do_work
            end
          end
        end
      RUBY
    end
  end

  context 'when `def enabled?` is at top level' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def enabled?
            true
          end
        end
      RUBY
    end
  end

  context 'when `def enabled?` is in a Hooks namespace' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Hooks
          class Setup
            def enabled?
              true
            end
          end
        end
      RUBY
    end
  end
end
