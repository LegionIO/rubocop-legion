# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects actor classes inside an `Actor` namespace that define `def action`
        # or `def manual` (self-contained actor patterns) without overriding
        # `def runner_class`. Without `runner_class`, the framework dispatches to the
        # wrong runner.
        #
        # @example
        #   # bad
        #   module Actor
        #     class Foo < Legion::Extensions::Actors::Interval
        #       def manual
        #         { success: true }
        #       end
        #     end
        #   end
        #
        #   # good
        #   module Actor
        #     class Foo < Legion::Extensions::Actors::Interval
        #       def runner_class
        #         self.class
        #       end
        #
        #       def manual
        #         { success: true }
        #       end
        #     end
        #   end
        class SelfContainedActorRunnerClass < RuboCop::Cop::Base
          MSG = 'Self-contained actors must override `runner_class` to return `self.class`.'

          def on_class(node)
            return unless inside_actor_namespace?(node)
            return unless action_or_manual?(node)
            return if runner_class?(node)

            add_offense(node.identifier)
          end

          private

          def inside_actor_namespace?(node)
            current = node.parent
            while current
              return true if current.module_type? && (current.identifier.short_name == :Actor)

              current = current.parent
            end
            false
          end

          def action_or_manual?(node)
            return false unless node.body

            node.body.each_node(:def).any? do |def_node|
              %i[action manual].include?(def_node.method_name)
            end
          end

          def runner_class?(node)
            return false unless node.body

            node.body.each_node(:def).any? do |def_node|
              def_node.method_name == :runner_class
            end
          end
        end
      end
    end
  end
end
