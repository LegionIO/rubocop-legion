# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects `extend Legion::Extensions::Core` without a `const_defined?` guard,
        # which causes failures when running specs in isolation without the full Legion
        # framework loaded.
        #
        # @example
        #   # bad
        #   extend Legion::Extensions::Core
        #
        #   # good
        #   extend Legion::Extensions::Core if Legion::Extensions.const_defined?(:Core)
        class CoreExtendGuard < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Guard `extend Core` with `if Legion::Extensions.const_defined?(:Core)` ' \
                'for standalone test compatibility.'

          GUARD_SUFFIX = ' if Legion::Extensions.const_defined?(:Core)'

          # @!method extend_core?(node)
          def_node_matcher :extend_core?, <<~PATTERN
            (send nil? :extend
              (const
                (const
                  (const nil? :Legion) :Extensions)
                :Core))
          PATTERN

          def on_send(node)
            return unless extend_core?(node)
            return if node.parent&.if_type?

            add_offense(node) do |corrector|
              corrector.insert_after(node, GUARD_SUFFIX)
            end
          end
        end
      end
    end
  end
end
