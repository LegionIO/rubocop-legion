# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::RunnerReturnHash do
  subject(:cop) { described_class.new }

  context 'when a runner method returns a string' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Runners
          module Foo
            def run
              return "error"
              ^^^^^^^^^^^^^^ Legion/Extension/RunnerReturnHash: Runner methods must return a Hash. Found explicit return of non-Hash value.
            end
          end
        end
      RUBY
    end
  end

  context 'when a runner method returns a symbol' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Runners
          module Foo
            def run
              return :error
              ^^^^^^^^^^^^^ Legion/Extension/RunnerReturnHash: Runner methods must return a Hash. Found explicit return of non-Hash value.
            end
          end
        end
      RUBY
    end
  end

  context 'when a runner method returns nil explicitly' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Runners
          module Foo
            def run
              return nil
              ^^^^^^^^^^ Legion/Extension/RunnerReturnHash: Runner methods must return a Hash. Found explicit return of non-Hash value.
            end
          end
        end
      RUBY
    end
  end

  context 'when a runner method returns a Hash literal' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Runners
          module Foo
            def run
              return { success: true }
            end
          end
        end
      RUBY
    end
  end

  context 'when a runner method uses bare `return`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Runners
          module Foo
            def run
              return
            end
          end
        end
      RUBY
    end
  end

  context 'when `return "x"` is outside a Runners module' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Foo
          def run
            return "error"
          end
        end
      RUBY
    end
  end
end
