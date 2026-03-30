# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Framework
        # Detects `synchronize` blocks nested inside other `synchronize` blocks,
        # which risks deadlock if the same mutex is re-acquired. Even with
        # different mutexes, nested locks require consistent ordering to avoid
        # deadlock.
        #
        # @example
        #   # bad
        #   @mutex.synchronize do
        #     @other_mutex.synchronize do
        #       work
        #     end
        #   end
        #
        #   # good — flatten into a single lock or use a dedicated lock object
        #   @mutex.synchronize do
        #     work
        #   end
        class MutexNestedSync < RuboCop::Cop::Base
          MSG = 'Nested `synchronize` detected. Risk of deadlock if the same mutex is re-acquired ' \
                'or if lock ordering is inconsistent.'

          def on_block(node)
            return unless synchronize_call?(node)
            return unless nested_inside_synchronize?(node)

            add_offense(node.send_node)
          end

          private

          def synchronize_call?(block_node)
            block_node.send_node.method_name == :synchronize
          end

          def nested_inside_synchronize?(node)
            current = node.parent
            while current
              return true if current.block_type? && synchronize_call?(current)

              current = current.parent
            end
            false
          end
        end
      end
    end
  end
end
