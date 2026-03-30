# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::RunnerPluralModule do
  subject(:cop) { described_class.new }

  context 'when `module Runner` is inside `Legion::Extensions::*`' do
    it 'registers an offense and auto-corrects to `module Runners`' do
      expect_offense(<<~RUBY)
        module Legion
          module Extensions
            module Foo
              module Runner
                     ^^^^^^ Legion/Extension/RunnerPluralModule: Use `module Runners` (plural), not `module Runner`. The framework discovers runners inside `Runners`.
              end
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Legion
          module Extensions
            module Foo
              module Runners
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when using compact namespace syntax' do
    it 'registers an offense for `module Runner` inside `Legion::Extensions::Foo`' do
      expect_offense(<<~RUBY)
        module Legion::Extensions::Foo
          module Runner
                 ^^^^^^ Legion/Extension/RunnerPluralModule: Use `module Runners` (plural), not `module Runner`. The framework discovers runners inside `Runners`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Legion::Extensions::Foo
          module Runners
          end
        end
      RUBY
    end
  end

  context 'when `module Runners` (plural) is used' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Legion
          module Extensions
            module Foo
              module Runners
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when `module Runner` is outside `Legion::Extensions` namespace' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module SomeOther
          module Runner
          end
        end
      RUBY
    end
  end

  context 'when `module Runner` is at top level' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Runner
        end
      RUBY
    end
  end
end
