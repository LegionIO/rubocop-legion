# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects `defined?(Legion::Transport)` guards and suggests using
        # `transport_connected?` from `Legion::Transport::Helper` instead.
        # The helper checks both that the module is loaded and that the
        # transport is actually connected, which is the correct semantics.
        #
        # @example
        #   # bad
        #   return unless defined?(Legion::Transport)
        #   if defined?(Legion::Transport) && Legion::Transport.connected?
        #
        #   # good
        #   return unless transport_connected?
        #   if transport_connected?
        class DefinedTransportGuard < RuboCop::Cop::Base
          MSG = 'Use `transport_connected?` instead of `defined?(Legion::Transport)`. ' \
                'Include `Legion::Transport::Helper` via the transport helper mixin.'

          # Cannot use def_node_matcher with `defined?` node type — Ruby treats
          # `defined?` as a keyword and the matcher DSL chokes on the `?` suffix.
          # Use manual AST inspection instead (same approach as LoggingGuard).
          def on_defined?(node)
            return false unless legion_transport_defined?(node)

            add_offense(node, message: MSG)
          end

          private

          def legion_transport_defined?(node)
            child = node.children.first
            return false unless child&.const_type?

            # Match exactly `Legion::Transport` — not sub-constants like `Legion::Transport::Message`
            parent_const = child.children.first
            parent_const&.const_type? &&
              parent_const.children == [nil, :Legion] &&
              child.children.last == :Transport
          end
        end
      end
    end
  end
end
