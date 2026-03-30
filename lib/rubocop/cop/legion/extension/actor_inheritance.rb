# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects actor classes inside an `Actor` namespace that do not inherit from
        # a recognized LEX actor base class. Every actor must inherit from one of:
        # `Every`, `Once`, `Poll`, `Subscription`, `Loop`, or `Nothing`.
        #
        # @example
        #   # bad
        #   module Actor
        #     class Foo
        #     end
        #   end
        #
        #   # bad
        #   module Actor
        #     class Foo < SomeOtherBase
        #     end
        #   end
        #
        #   # good
        #   module Actor
        #     class Foo < Legion::Extensions::Actors::Every
        #     end
        #   end
        class ActorInheritance < RuboCop::Cop::Base
          MSG = 'Actor must inherit from a recognized base: Every, Once, Poll, Subscription, Loop, or Nothing.'

          RECOGNIZED_BASES = %i[Every Once Poll Subscription Loop Nothing].to_set.freeze

          def on_class(node)
            return unless inside_actor_namespace?(node)

            superclass = node.parent_class
            return if superclass && recognized_base?(superclass)

            add_offense(node.identifier)
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

          def recognized_base?(superclass_node)
            # Handle both `< Every` and `< Legion::Extensions::Actors::Every`
            leaf = superclass_node
            leaf = leaf.children.last while leaf.const_type? && leaf.children.last.is_a?(Symbol) == false
            RECOGNIZED_BASES.include?(leaf.children.last)
          end
        end
      end
    end
  end
end
