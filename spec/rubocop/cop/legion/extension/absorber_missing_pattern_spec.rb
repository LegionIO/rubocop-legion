# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::AbsorberMissingPattern do
  subject(:cop) { described_class.new }

  context 'when an absorber class does not call `pattern`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Absorbers
          class Foo
                ^^^ Legion/Extension/AbsorberMissingPattern: Absorber classes must call the `pattern` DSL method to match events.
            def absorb(event)
              process(event)
            end
          end
        end
      RUBY
    end
  end

  context 'when an absorber class calls `pattern`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Absorbers
          class Foo
            pattern 'some.event.*'

            def absorb(event)
              process(event)
            end
          end
        end
      RUBY
    end
  end

  context 'when a class is outside the Absorbers namespace' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def absorb(event)
            process(event)
          end
        end
      RUBY
    end
  end

  context 'when an absorber class is empty' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Absorbers
          class Bar
                ^^^ Legion/Extension/AbsorberMissingPattern: Absorber classes must call the `pattern` DSL method to match events.
          end
        end
      RUBY
    end
  end
end
