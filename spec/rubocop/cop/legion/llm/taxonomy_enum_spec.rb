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

    it 'registers an offense for unknown tier even without other taxonomy keys' do
      expect_offense(<<~RUBY)
        { tier: :premium, provider: :anthropic }
          ^^^^^^^^^^^^^^ Unknown tier `premium`. Valid: local, fleet, cloud, frontier, direct.
      RUBY
    end
  end

  context 'type validation' do
    it 'registers an offense for unknown type when in taxonomy context' do
      expect_offense(<<~RUBY)
        { tier: :cloud, type: :inferencing }
                        ^^^^^^^^^^^^^^^^^^ Unknown type `inferencing`. Valid: inference, embedding, moderation, rerank, image.
      RUBY
    end

    it 'does not register an offense for valid type in taxonomy context' do
      expect_no_offenses(<<~RUBY)
        { tier: :cloud, type: :inference }
      RUBY
    end

    it 'does not register an offense for valid type :embedding in taxonomy context' do
      expect_no_offenses(<<~RUBY)
        { tier: :fleet, type: :embedding }
      RUBY
    end

    it 'does not flag :type alone without taxonomy context' do
      expect_no_offenses(<<~RUBY)
        { type: :string }
      RUBY
    end

    it 'does not flag :type with unrelated keys' do
      expect_no_offenses(<<~RUBY)
        { type: :integer, null: false, default: 0 }
      RUBY
    end

    it 'flags :type when circuit_state is also present' do
      expect_offense(<<~RUBY)
        { circuit_state: :closed, type: :inferencing }
                                  ^^^^^^^^^^^^^^^^^^ Unknown type `inferencing`. Valid: inference, embedding, moderation, rerank, image.
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

  context 'bracket assignment' do
    it 'registers an offense for unknown circuit_state via []=' do
      expect_offense(<<~RUBY)
        health[:circuit_state] = :half_opened
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unknown circuit_state `half_opened`. Valid: closed, open, half_open.
      RUBY
    end

    it 'does not register an offense for valid circuit_state via []=' do
      expect_no_offenses(<<~RUBY)
        health[:circuit_state] = :half_open
      RUBY
    end

    it 'registers an offense for unknown tier via []=' do
      expect_offense(<<~RUBY)
        lane[:tier] = :fronteir
        ^^^^^^^^^^^^^^^^^^^^^^^ Unknown tier `fronteir`. Valid: local, fleet, cloud, frontier, direct.
      RUBY
    end
  end

  context 'non-taxonomy pairs' do
    it 'does not register an offense for unrelated hash keys' do
      expect_no_offenses(<<~RUBY)
        { provider: :anthropic, model: :unknown_model }
      RUBY
    end

    it 'does not flag common Ruby hashes with :type key' do
      expect_no_offenses(<<~RUBY)
        column :name, type: :varchar
      RUBY
    end

    it 'does not flag schema definitions' do
      expect_no_offenses(<<~RUBY)
        { name: :user_id, type: :integer, null: false }
      RUBY
    end
  end
end
