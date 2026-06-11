# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Framework
        # Bans defining methods matching `/_direct\z/` on `Legion::LLM` modules.
        # Per G16, all pipeline bypasses (`chat_direct`, `embed_direct`,
        # `structured_direct`) are removed — internal callers route through the
        # governed pipeline with an appropriate profile.
        #
        # No auto-correct is provided because the fix requires routing through
        # the inference pipeline.
        #
        # @example
        #   # bad
        #   module Legion::LLM
        #     def chat_direct(message:)
        #       # bypasses metering, audit, ledger
        #     end
        #   end
        #
        #   # bad
        #   module Legion::LLM
        #     def self.embed_direct(text:)
        #     end
        #   end
        #
        #   # good
        #   module Legion::LLM
        #     def chat(message:)
        #       # routes through pipeline
        #     end
        #   end
        class NoDirectDispatch < Base
          MSG = 'Method `%<name>s` matches `/_direct\\z/` on a `Legion::LLM` module. ' \
                'Pipeline bypasses are not allowed — route through the governed pipeline.'

          DIRECT_PATTERN = /_direct\z/

          def on_def(node)
            return unless node.method_name.to_s.match?(DIRECT_PATTERN)
            return unless inside_legion_llm?(node)

            add_offense(node.loc.name, message: format(MSG, name: node.method_name))
          end

          def on_defs(node)
            return unless node.method_name.to_s.match?(DIRECT_PATTERN)
            return unless inside_legion_llm?(node)

            add_offense(node.loc.name, message: format(MSG, name: node.method_name))
          end

          private

          def inside_legion_llm?(node)
            node.each_ancestor(:module, :class).any? do |ancestor|
              legion_llm_module?(ancestor)
            end
          end

          def legion_llm_module?(mod_node)
            return false unless mod_node.module_type?

            # Check compact form: Legion::LLM or Legion::LLM::Something
            ident = mod_node.identifier
            return true if compact_legion_llm?(ident)

            # Check nested form: module Legion; module LLM; ...
            # The identifier is just `LLM` but parent is `module Legion`
            return true if nested_legion_llm?(mod_node)

            false
          end

          def compact_legion_llm?(ident)
            parts = const_parts(ident)
            parts.length >= 2 && parts[0] == :Legion && parts[1] == :LLM
          end

          def nested_legion_llm?(mod_node)
            return false unless mod_node.identifier.const_type?
            return false unless mod_node.identifier.children.last == :LLM

            # Check if parent module is `Legion`
            parent = mod_node.parent
            return false unless parent&.module_type?
            return false unless parent&.identifier&.const_type?

            parent.identifier.children.last == :Legion
          end

          def const_parts(node)
            return [] unless node&.const_type?

            child = node.children.first
            name = node.children.last
            if child&.const_type?
              const_parts(child) + [name]
            else
              [name]
            end
          end
        end
      end
    end
  end
end
