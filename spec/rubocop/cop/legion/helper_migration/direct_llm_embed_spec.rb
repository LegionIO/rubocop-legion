# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::HelperMigration::DirectLlmEmbed do
  subject(:cop) { described_class.new }

  context 'with Legion::LLM.embed' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Legion::LLM.embed(text)
        ^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DirectLlmEmbed: Use `llm_embed` instead of `Legion::LLM.embed`. Include `Legion::Extensions::Helpers::LLM` via the LLM helper mixin.
      RUBY
    end

    it 'auto-corrects to llm_embed' do
      expect_offense(<<~RUBY)
        Legion::LLM.embed(text)
        ^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DirectLlmEmbed: Use `llm_embed` instead of `Legion::LLM.embed`. Include `Legion::Extensions::Helpers::LLM` via the LLM helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        llm_embed(text)
      RUBY
    end
  end

  context 'with Legion::LLM.embed and kwargs' do
    it 'registers an offense and preserves kwargs' do
      expect_offense(<<~RUBY)
        Legion::LLM.embed(text, provider: :bedrock, dimensions: 1024)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DirectLlmEmbed: Use `llm_embed` instead of `Legion::LLM.embed`. Include `Legion::Extensions::Helpers::LLM` via the LLM helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        llm_embed(text, provider: :bedrock, dimensions: 1024)
      RUBY
    end
  end

  context 'with Legion::LLM.embed and array argument' do
    it 'registers an offense and preserves array arg' do
      expect_offense(<<~RUBY)
        Legion::LLM.embed(chunks)
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/HelperMigration/DirectLlmEmbed: Use `llm_embed` instead of `Legion::LLM.embed`. Include `Legion::Extensions::Helpers::LLM` via the LLM helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        llm_embed(chunks)
      RUBY
    end
  end

  context 'when calling other Legion::LLM methods' do
    it 'does not flag Legion::LLM.ask' do
      expect_no_offenses(<<~RUBY)
        Legion::LLM.ask(message: "hello")
      RUBY
    end

    it 'does not flag Legion::LLM.chat' do
      expect_no_offenses(<<~RUBY)
        Legion::LLM.chat(messages: [])
      RUBY
    end
  end

  context 'when calling embed on a different object' do
    it 'does not flag other_module.embed' do
      expect_no_offenses(<<~RUBY)
        SomeOther.embed(text)
      RUBY
    end

    it 'does not flag llm_embed helper' do
      expect_no_offenses(<<~RUBY)
        llm_embed(text)
      RUBY
    end
  end
end
