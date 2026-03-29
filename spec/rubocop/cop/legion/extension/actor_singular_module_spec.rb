# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::ActorSingularModule do
  subject(:cop) { described_class.new }

  context 'when `module Actors` is inside `Legion::Extensions::*`' do
    it 'registers an offense and auto-corrects to `module Actor`' do
      expect_offense(<<~RUBY)
        module Legion
          module Extensions
            module Foo
              module Actors
                     ^^^^^^ Legion/Extension/ActorSingularModule: Use `module Actor` (singular), not `module Actors`. The framework discovers actors inside `Actor`.
              end
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Legion
          module Extensions
            module Foo
              module Actor
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when using compact namespace syntax' do
    it 'registers an offense for `module Actors` inside `Legion::Extensions::Foo`' do
      expect_offense(<<~RUBY)
        module Legion::Extensions::Foo
          module Actors
                 ^^^^^^ Legion/Extension/ActorSingularModule: Use `module Actor` (singular), not `module Actors`. The framework discovers actors inside `Actor`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Legion::Extensions::Foo
          module Actor
          end
        end
      RUBY
    end
  end

  context 'when `module Actor` (singular) is used' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Legion
          module Extensions
            module Foo
              module Actor
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when `module Actors` is outside `Legion::Extensions` namespace' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module SomeOther
          module Actors
          end
        end
      RUBY
    end
  end

  context 'when `module Actors` is at top level' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Actors
        end
      RUBY
    end
  end
end
