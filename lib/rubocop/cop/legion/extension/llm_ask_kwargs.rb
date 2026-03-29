# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects calls to `Legion::LLM.ask` with extra keyword arguments beyond
        # `message:`. The method signature is `ask(message:)` with no splat — extra
        # kwargs raise `ArgumentError` at runtime.
        #
        # @example
        #   # bad
        #   Legion::LLM.ask(message: "hello", caller: self)
        #
        #   # good
        #   Legion::LLM.ask(message: "hello")
        class LlmAskKwargs < RuboCop::Cop::Base
          RESTRICT_ON_SEND = %i[ask].freeze

          MSG = '`Legion::LLM.ask` only accepts `message:` keyword. ' \
                'Remove extra keyword arguments.'

          # @!method legion_llm_ask?(node)
          def_node_matcher :legion_llm_ask?, <<~PATTERN
            (send
              (const (const nil? :Legion) :LLM)
              :ask
              ...)
          PATTERN

          def on_send(node)
            return unless legion_llm_ask?(node)

            hash_arg = node.arguments.find(&:hash_type?)
            return unless hash_arg

            extra_keys = hash_arg.pairs.reject do |pair|
              pair.key.sym_type? && pair.key.value == :message
            end

            add_offense(node) if extra_keys.any?
          end
        end
      end
    end
  end
end
