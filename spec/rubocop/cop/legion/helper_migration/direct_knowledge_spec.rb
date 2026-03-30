# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/helper_migration/direct_knowledge'

RSpec.describe RuboCop::Cop::Legion::HelperMigration::DirectKnowledge, :config do
  context 'with Legion::Apollo.query' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::Apollo.query(text: 'search')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `query_knowledge` instead of `Legion::Apollo.query`. Include the knowledge helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        query_knowledge(text: 'search')
      RUBY
    end
  end

  context 'with Legion::Apollo.ingest' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        Legion::Apollo.ingest(content, tags: [:foo])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ingest_knowledge` instead of `Legion::Apollo.ingest`. Include the knowledge helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        ingest_knowledge(content, tags: [:foo])
      RUBY
    end
  end

  context 'with Legion::Apollo::Local.query' do
    it 'registers an offense and auto-corrects with scope: :local' do
      expect_offense(<<~RUBY)
        Legion::Apollo::Local.query(text: 'search')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `query_knowledge` instead of `Legion::Apollo::Local.query`. Include the knowledge helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        query_knowledge(text: 'search', scope: :local)
      RUBY
    end
  end

  context 'with Legion::Apollo::Local.ingest' do
    it 'registers an offense and auto-corrects with scope: :local' do
      expect_offense(<<~RUBY)
        Legion::Apollo::Local.ingest(content)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ingest_knowledge` instead of `Legion::Apollo::Local.ingest`. Include the knowledge helper mixin.
      RUBY

      expect_correction(<<~RUBY)
        ingest_knowledge(content, scope: :local)
      RUBY
    end
  end

  context 'when calling methods on other receivers' do
    it 'does not flag query_knowledge helper' do
      expect_no_offenses('query_knowledge(text: "search")')
    end

    it 'does not flag ingest_knowledge helper' do
      expect_no_offenses('ingest_knowledge(content)')
    end

    it 'does not flag Other::Apollo.query' do
      expect_no_offenses('Other::Apollo.query(text: "search")')
    end

    it 'does not flag Legion::Apollo.started?' do
      expect_no_offenses('Legion::Apollo.started?')
    end
  end
end
