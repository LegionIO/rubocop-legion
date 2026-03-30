# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::AbsorberMissingAbsorbMethod do
  subject(:cop) { described_class.new }

  context 'when an absorber class does not define `absorb`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Absorbers
          class Foo
                ^^^ Legion/Extension/AbsorberMissingAbsorbMethod: Absorber classes must define an `absorb` method to handle matched events.
            pattern 'some.event.*'
          end
        end
      RUBY
    end
  end

  context 'when an absorber class defines `absorb`' do
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
          pattern 'some.event.*'
        end
      RUBY
    end
  end

  context 'when an absorber class is empty' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Absorbers
          class Bar
                ^^^ Legion/Extension/AbsorberMissingAbsorbMethod: Absorber classes must define an `absorb` method to handle matched events.
          end
        end
      RUBY
    end
  end
end
