# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/llm/taxonomy_enum'

RSpec.describe RuboCop::Cop::Legion::Llm::TaxonomyEnum, :config do
  context 'tier validation' do
    it 'registers an offense for unknown tier literal' do
      expect_offense(<<~RUBY)
        { tier: :fronteir }
          ^^^^^^^^^^^^^^^ Unknown tier `fronteir`. Valid: local, fleet, cloud, frontier, direct.
      RUBY
    end

    it 'does not register an offense for valid tier :frontier' do
      expect_no_offenses(<<~RUBY)
        { tier: :frontier }
      RUBY
    end

    it 'does not register an offense for valid tier :local' do
      expect_no_offenses(<<~RUBY)
        { tier: :local }
      RUBY
    end

    it 'does not register an offense for valid tier :fleet' do
      expect_no_offenses(<<~RUBY)
        { tier: :fleet }
      RUBY
    end
  end

  context 'type validation' do
    it 'registers an offense for unknown type literal' do
      expect_offense(<<~RUBY)
        { type: :inferencing }
          ^^^^^^^^^^^^^^^^^^ Unknown type `inferencing`. Valid: inference, embedding, moderation, rerank, image.
      RUBY
    end

    it 'does not register an offense for valid type :inference' do
      expect_no_offenses(<<~RUBY)
        { type: :inference }
      RUBY
    end

    it 'does not register an offense for valid type :embedding' do
      expect_no_offenses(<<~RUBY)
        { type: :embedding }
      RUBY
    end
  end

  context 'circuit_state validation' do
    it 'registers an offense for unknown circuit_state in hash literal' do
      expect_offense(<<~RUBY)
        { circuit_state: :half_opened }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unknown circuit_state `half_opened`. Valid: closed, open, half_open.
      RUBY
    end

    it 'does not register an offense for valid circuit_state :half_open' do
      expect_no_offenses(<<~RUBY)
        { circuit_state: :half_open }
      RUBY
    end

    it 'does not register an offense for valid circuit_state :closed' do
      expect_no_offenses(<<~RUBY)
        { circuit_state: :closed }
      RUBY
    end
  end

  context 'non-taxonomy pairs' do
    it 'does not register an offense for unrelated hash keys' do
      expect_no_offenses(<<~RUBY)
        { provider: :anthropic, model: :unknown_model }
      RUBY
    end
  end
end
