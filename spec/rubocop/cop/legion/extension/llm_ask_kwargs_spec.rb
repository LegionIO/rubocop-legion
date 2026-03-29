# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::LlmAskKwargs do
  subject(:cop) { described_class.new }

  context 'when `Legion::LLM.ask` is called with extra kwargs' do
    it 'registers an offense for `caller:` kwarg' do
      expect_offense(<<~RUBY)
        Legion::LLM.ask(message: "hi", caller: self)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/Extension/LlmAskKwargs: `Legion::LLM.ask` only accepts `message:` keyword. Remove extra keyword arguments.
      RUBY
    end
  end

  context 'when `Legion::LLM.ask` is called with multiple extra kwargs' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::LLM.ask(message: "hi", caller: self, model: "claude")
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/Extension/LlmAskKwargs: `Legion::LLM.ask` only accepts `message:` keyword. Remove extra keyword arguments.
      RUBY
    end
  end

  context 'when `Legion::LLM.ask` is called with only `message:` kwarg' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Legion::LLM.ask(message: "hi")
      RUBY
    end
  end

  context 'when `ask` is called on a different object' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        other.ask(message: "hi", extra: true)
      RUBY
    end
  end

  context 'when `ask` is called on a different `LLM` constant' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        SomeLLM.ask(message: "hi", extra: true)
      RUBY
    end
  end
end
