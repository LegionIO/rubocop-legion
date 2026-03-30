# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects direct calls to `Legion::LLM` methods and suggests using
        # the `llm_*` helpers from `Legion::Extensions::Helpers::LLM`.
        #
        # @example
        #   # bad
        #   Legion::LLM.embed(text)
        #   Legion::LLM.chat(message, intent: :moderate)
        #   Legion::LLM.ask(message: 'hello')
        #   Legion::LLM.structured(messages: [], schema: {})
        #   Legion::LLM.embed_batch(texts)
        #
        #   # good
        #   llm_embed(text)
        #   llm_chat(message, intent: :moderate)
        #   llm_ask(message: 'hello')
        #   llm_structured(messages: [], schema: {})
        #   llm_embed_batch(texts)
        class DirectLlm < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `%<helper>s` instead of `Legion::LLM.%<method>s`. ' \
                'Include the LLM helper mixin.'

          RESTRICT_ON_SEND = %i[embed chat ask structured embed_batch].freeze

          HELPER_MAP = {
            embed: 'llm_embed',
            chat: 'llm_chat',
            ask: 'llm_ask',
            structured: 'llm_structured',
            embed_batch: 'llm_embed_batch'
          }.freeze

          # @!method legion_llm_call?(node)
          def_node_matcher :legion_llm_call?, <<~PATTERN
            (send (const (const nil? :Legion) :LLM) {:embed :chat :ask :structured :embed_batch} ...)
          PATTERN

          def on_send(node)
            return unless legion_llm_call?(node)

            method_name = node.method_name
            helper = HELPER_MAP[method_name]
            message = format(MSG, helper: helper, method: method_name)

            add_offense(node, message: message) do |corrector|
              args_source = node.arguments.map(&:source).join(', ')
              corrector.replace(node, "#{helper}(#{args_source})")
            end
          end
        end
      end
    end
  end
end
