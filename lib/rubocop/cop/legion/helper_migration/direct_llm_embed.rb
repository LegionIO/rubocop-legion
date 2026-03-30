# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects direct calls to `Legion::LLM.embed` and suggests using the
        # `llm_embed` helper from `Legion::Extensions::Helpers::LLM`.
        #
        # @example
        #   # bad
        #   Legion::LLM.embed(text)
        #   Legion::LLM.embed(text, provider: :bedrock)
        #
        #   # good
        #   llm_embed(text)
        #   llm_embed(text, provider: :bedrock)
        class DirectLlmEmbed < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `llm_embed` instead of `Legion::LLM.embed`. ' \
                'Include `Legion::Extensions::Helpers::LLM` via the LLM helper mixin.'

          RESTRICT_ON_SEND = %i[embed].freeze

          # @!method legion_llm_embed?(node)
          def_node_matcher :legion_llm_embed?, <<~PATTERN
            (send (const (const nil? :Legion) :LLM) :embed ...)
          PATTERN

          def on_send(node)
            return unless legion_llm_embed?(node)

            add_offense(node, message: MSG) do |corrector|
              args_source = node.arguments.map(&:source).join(', ')
              corrector.replace(node, "llm_embed(#{args_source})")
            end
          end
        end
      end
    end
  end
end
