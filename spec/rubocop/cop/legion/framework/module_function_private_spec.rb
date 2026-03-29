# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Framework::ModuleFunctionPrivate do
  subject(:cop) { described_class.new }

  it 'registers an offense on private when both module_function and private are present' do
    expect_offense(<<~RUBY)
      module Helpers
        module_function

        def foo; end

        private
        ^^^^^^^ Legion/Framework/ModuleFunctionPrivate: `private` after `module_function` resets visibility to instance-only. Do not use both in the same module.

        def bar; end
      end
    RUBY
  end

  it 'does not register an offense for module_function only' do
    expect_no_offenses(<<~RUBY)
      module Helpers
        module_function

        def foo; end
      end
    RUBY
  end

  it 'does not register an offense for private only' do
    expect_no_offenses(<<~RUBY)
      module Helpers
        private

        def bar; end
      end
    RUBY
  end

  it 'does not register an offense for targeted module_function :foo (with args)' do
    expect_no_offenses(<<~RUBY)
      module Helpers
        def foo; end
        module_function :foo

        private

        def bar; end
      end
    RUBY
  end

  it 'does not register an offense for a plain class' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def bar; end
      end
    RUBY
  end
end
