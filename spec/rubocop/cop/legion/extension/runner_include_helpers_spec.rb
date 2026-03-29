# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::RunnerIncludeHelpers do
  subject(:cop) { described_class.new }

  context 'when a runner module has methods but no include or extend self' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Runners
          module Foo
                 ^^^ Legion/Extension/RunnerIncludeHelpers: Runner modules need `include Helpers::Lex` or `extend self` so actors can call methods via module.
            def run
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when a runner module has `include Helpers::Lex`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Runners
          module Foo
            include Helpers::Lex

            def run
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when a runner module has `include Legion::Extensions::Helpers::Lex`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Runners
          module Foo
            include Legion::Extensions::Helpers::Lex

            def run
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when a runner module has `extend self`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Runners
          module Foo
            extend self

            def run
              { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when a runner module is empty (no method definitions)' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Runners
          module Foo
          end
        end
      RUBY
    end
  end

  context 'when a module with methods is outside `Runners`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module SomeModule
          def run
            { success: true }
          end
        end
      RUBY
    end
  end
end
