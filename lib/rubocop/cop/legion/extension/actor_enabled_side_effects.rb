# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects `def enabled?` methods inside actor classes. The `enabled?`
        # method runs during extension loading before `delay` is honoured,
        # so it must be cheap and side-effect-free (no network calls, mutex
        # locks, or I/O).
        #
        # @example
        #   # bad — network call during boot
        #   module Actor
        #     class Check < Every
        #       def enabled?
        #         Legion::Transport.connected?
        #       end
        #     end
        #   end
        #
        #   # good — cheap Settings lookup
        #   module Actor
        #     class Check < Every
        #       def enabled?
        #         !Legion::Settings[:check].nil?
        #       end
        #     end
        #   end
        class ActorEnabledSideEffects < RuboCop::Cop::Base
          MSG = '`enabled?` runs during extension loading, before `delay`. ' \
                'Keep it cheap and side-effect-free (no network calls, mutex locks, or I/O).'

          def on_def(node)
            return unless node.method_name == :enabled?
            return unless inside_actor_namespace?(node)

            add_offense(node)
          end

          private

          def inside_actor_namespace?(node)
            current = node.parent
            while current
              return true if current.module_type? && current.identifier.short_name == :Actor

              current = current.parent
            end
            false
          end
        end
      end
    end
  end
end
