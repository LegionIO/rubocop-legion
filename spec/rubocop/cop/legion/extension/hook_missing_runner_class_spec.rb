# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::HookMissingRunnerClass do
  subject(:cop) { described_class.new }

  context 'when a hook class has no `runner_class` method' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Hooks
          class Auth
                ^^^^ Legion/Extension/HookMissingRunnerClass: Hook classes must override `runner_class`. Without it, the framework dispatches to nil.
            def handle(request)
              { status: 200 }
            end
          end
        end
      RUBY
    end
  end

  context 'when a hook class defines `runner_class`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Hooks
          class Auth
            def runner_class
              Runners::Auth
            end

            def handle(request)
              { status: 200 }
            end
          end
        end
      RUBY
    end
  end

  context 'when a class is outside the Hooks namespace' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Auth
          def handle(request)
            { status: 200 }
          end
        end
      RUBY
    end
  end

  context 'when a hook class is empty' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Hooks
          class Callback
                ^^^^^^^^ Legion/Extension/HookMissingRunnerClass: Hook classes must override `runner_class`. Without it, the framework dispatches to nil.
          end
        end
      RUBY
    end
  end
end
