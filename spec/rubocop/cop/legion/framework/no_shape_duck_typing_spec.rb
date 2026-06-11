# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/framework/no_shape_duck_typing'

RSpec.describe RuboCop::Cop::Legion::Framework::NoShapeDuckTyping, :config do
  context 'respond_to? on canonical shape methods' do
    it 'registers an offense for respond_to?(:thinking)' do
      expect_offense(<<~RUBY)
        response.respond_to?(:thinking)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use canonical struct access instead of `respond_to?(:thinking)`. Downstream of translators, the shape is guaranteed.
      RUBY
    end

    it 'registers an offense for respond_to?(:tool_calls)' do
      expect_offense(<<~RUBY)
        response.respond_to?(:tool_calls)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use canonical struct access instead of `respond_to?(:tool_calls)`. Downstream of translators, the shape is guaranteed.
      RUBY
    end

    it 'registers an offense for respond_to?(:content)' do
      expect_offense(<<~RUBY)
        response.respond_to?(:content)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use canonical struct access instead of `respond_to?(:content)`. Downstream of translators, the shape is guaranteed.
      RUBY
    end

    it 'registers an offense for respond_to?(:stop_reason)' do
      expect_offense(<<~RUBY)
        response.respond_to?(:stop_reason)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use canonical struct access instead of `respond_to?(:stop_reason)`. Downstream of translators, the shape is guaranteed.
      RUBY
    end

    it 'registers an offense for respond_to? with string argument' do
      expect_offense(<<~RUBY)
        response.respond_to?("thinking")
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use canonical struct access instead of `respond_to?(:thinking)`. Downstream of translators, the shape is guaranteed.
      RUBY
    end

    it 'registers an offense for respond_to? on chunk variable' do
      expect_offense(<<~RUBY)
        chunk.respond_to?(:thinking)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use canonical struct access instead of `respond_to?(:thinking)`. Downstream of translators, the shape is guaranteed.
      RUBY
    end
  end

  context 'string-key fallback access' do
    it 'registers an offense for tc[:name] || tc["name"]' do
      expect_offense(<<~RUBY)
        tc[:name] || tc["name"]
        ^^^^^^^^^^^^^^^^^^^^^^^ String-key fallback `name` suggests duck-typed access. Use canonical struct access or symbol keys consistently.
      RUBY
    end

    it 'registers an offense for tc["name"] || tc[:name]' do
      expect_offense(<<~RUBY)
        tc["name"] || tc[:name]
        ^^^^^^^^^^^^^^^^^^^^^^^ String-key fallback `name` suggests duck-typed access. Use canonical struct access or symbol keys consistently.
      RUBY
    end

    it 'registers an offense for response[:content] || response["content"]' do
      expect_offense(<<~RUBY)
        response[:content] || response["content"]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ String-key fallback `content` suggests duck-typed access. Use canonical struct access or symbol keys consistently.
      RUBY
    end
  end

  context 'acceptable patterns' do
    it 'does not register an offense for respond_to? on non-canonical methods' do
      expect_no_offenses(<<~RUBY)
        response.respond_to?(:custom_field)
      RUBY
    end

    it 'does not register an offense for direct struct access' do
      expect_no_offenses(<<~RUBY)
        response.thinking
      RUBY
    end

    it 'does not register an offense for symbol-only hash access' do
      expect_no_offenses(<<~RUBY)
        tc[:name]
      RUBY
    end

    it 'does not register an offense for string-only hash access' do
      expect_no_offenses(<<~RUBY)
        tc["name"]
      RUBY
    end

    it 'does not register an offense for || between different variables' do
      expect_no_offenses(<<~RUBY)
        a[:name] || b["name"]
      RUBY
    end

    it 'does not register an offense for || with non-hash expressions' do
      expect_no_offenses(<<~RUBY)
        val || default_val
      RUBY
    end

    it 'does not register an offense for respond_to? with third argument' do
      expect_no_offenses(<<~RUBY)
        response.respond_to?(:thinking, true)
      RUBY
    end
  end
end
