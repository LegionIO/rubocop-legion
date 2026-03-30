# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/helper_migration/direct_llm'

RSpec.describe RuboCop::Cop::Legion::HelperMigration::DirectLlm, :config do
  context 'with Legion::LLM.embed' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::LLM.embed(text)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `llm_embed` instead of `Legion::LLM.embed`. Include the LLM helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        llm_embed(text)
      RUBY
    end

    it 'preserves kwargs' do
      expect_offense(<<~RUBY)
        Legion::LLM.embed(text, provider: :bedrock, dimensions: 1024)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `llm_embed` instead of `Legion::LLM.embed`. Include the LLM helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        llm_embed(text, provider: :bedrock, dimensions: 1024)
      RUBY
    end
  end

  context 'with Legion::LLM.chat' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::LLM.chat(message, intent: :moderate)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `llm_chat` instead of `Legion::LLM.chat`. Include the LLM helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        llm_chat(message, intent: :moderate)
      RUBY
    end
  end

  context 'with Legion::LLM.ask' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::LLM.ask(message: 'hello')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `llm_ask` instead of `Legion::LLM.ask`. Include the LLM helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        llm_ask(message: 'hello')
      RUBY
    end
  end

  context 'with Legion::LLM.structured' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::LLM.structured(messages: [], schema: {})
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `llm_structured` instead of `Legion::LLM.structured`. Include the LLM helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        llm_structured(messages: [], schema: {})
      RUBY
    end
  end

  context 'with Legion::LLM.embed_batch' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::LLM.embed_batch(texts)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `llm_embed_batch` instead of `Legion::LLM.embed_batch`. Include the LLM helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        llm_embed_batch(texts)
      RUBY
    end
  end

  context 'when calling other Legion::LLM methods' do
    it 'does not flag Legion::LLM.started?' do
      expect_no_offenses(<<~RUBY)
        Legion::LLM.started?
      RUBY
    end
  end

  context 'when calling methods on a different receiver' do
    it 'does not flag SomeOther.embed' do
      expect_no_offenses('SomeOther.embed(text)')
    end

    it 'does not flag llm_embed helper' do
      expect_no_offenses('llm_embed(text)')
    end

    it 'does not flag llm_chat helper' do
      expect_no_offenses('llm_chat(message)')
    end
  end
end
