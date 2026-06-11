# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/framework/no_direct_dispatch'
# rubocop:disable Lint/ConstantDefinitionInBlock

RSpec.describe RuboCop::Cop::Legion::Framework::NoDirectDispatch, :config do
  MSG = 'Method `%<name>s` matches `/_direct\z/` on a `Legion::LLM` module. ' \
        'Pipeline bypasses are not allowed — route through the governed pipeline.'

  MSG_CHAT = format(MSG, name: 'chat_direct')
  MSG_EMBED = format(MSG, name: 'embed_direct')
  MSG_STRUCTURED = format(MSG, name: 'structured_direct')

  context 'instance methods ending with _direct' do
    # line=2, col=6, len=11
    it 'registers an offense for chat_direct in Legion::LLM' do
      expect_offense(<<~RUBY)
        module Legion::LLM
          def chat_direct(message:)
              #{'^' * 11} #{MSG_CHAT}
          end
        end
      RUBY
    end

    # line=2, col=6, len=12
    it 'registers an offense for embed_direct in Legion::LLM' do
      expect_offense(<<~RUBY)
        module Legion::LLM
          def embed_direct(text:)
              #{'^' * 12} #{MSG_EMBED}
          end
        end
      RUBY
    end

    # line=2, col=6, len=17
    it 'registers an offense for structured_direct in nested Legion::LLM module' do
      expect_offense(<<~RUBY)
        module Legion::LLM::Pipeline
          def structured_direct(prompt:)
              #{'^' * 17} #{MSG_STRUCTURED}
          end
        end
      RUBY
    end
  end

  context 'class methods ending with _direct' do
    # line=2, col=11, len=11
    it 'registers an offense for self.chat_direct' do
      expect_offense(<<~RUBY)
        module Legion::LLM
          def self.chat_direct(message:)
                   #{'^' * 11} #{MSG_CHAT}
          end
        end
      RUBY
    end

    # line=2, col=11, len=12
    it 'registers an offense for self.embed_direct in nested module' do
      expect_offense(<<~RUBY)
        module Legion::LLM::Inference
          def self.embed_direct(text:)
                   #{'^' * 12} #{MSG_EMBED}
          end
        end
      RUBY
    end
  end

  context 'methods in Legion::LLM top-level module' do
    # line=3, col=8, len=11
    it 'registers an offense for _direct method in Legion::LLM directly' do
      expect_offense(<<~RUBY)
        module Legion
          module LLM
            def chat_direct(message:)
                #{'^' * 11} #{MSG_CHAT}
            end
          end
        end
      RUBY
    end
  end

  context 'acceptable patterns' do
    it 'does not register an offense for non-_direct methods in Legion::LLM' do
      expect_no_offenses(<<~RUBY)
        module Legion::LLM
          def chat(message:)
          end
        end
      RUBY
    end

    it 'does not register an offense for _direct methods outside Legion::LLM' do
      expect_no_offenses(<<~RUBY)
        module MyApp
          def chat_direct(message:)
          end
        end
      RUBY
    end

    it 'does not register an offense for _direct methods in Legion::Logging' do
      expect_no_offenses(<<~RUBY)
        module Legion::Logging
          def log_direct(message:)
          end
        end
      RUBY
    end

    it 'does not register an offense for methods containing direct but not ending with _direct' do
      expect_no_offenses(<<~RUBY)
        module Legion::LLM
          def direct_chat(message:)
          end
        end
      RUBY
    end

    it 'does not register an offense for methods ending with direct but no underscore' do
      expect_no_offenses(<<~RUBY)
        module Legion::LLM
          def direct(message:)
          end
        end
      RUBY
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock
end
