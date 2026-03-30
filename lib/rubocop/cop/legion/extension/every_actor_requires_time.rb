# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects actor classes that inherit from `Every` or `Poll` but do not call
        # the `time` DSL method. Without `time`, the framework has no interval and
        # the actor will not schedule correctly.
        #
        # @example
        #   # bad
        #   module Actor
        #     class Foo < Legion::Extensions::Actors::Every
        #     end
        #   end
        #
        #   # good
        #   module Actor
        #     class Foo < Legion::Extensions::Actors::Every
        #       time 60
        #     end
        #   end
        class EveryActorRequiresTime < RuboCop::Cop::Base
          MSG = 'Every/Poll actors must call the `time` DSL method to set the interval.'

          INTERVAL_BASES = %i[Every Poll].to_set.freeze

          def on_class(node)
            return unless inside_actor_namespace?(node)

            superclass = node.parent_class
            return unless superclass && interval_base?(superclass)
            return if calls_time?(node)

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

          def interval_base?(superclass_node)
            leaf = superclass_node
            leaf = leaf.children.last while leaf.const_type? && leaf.children.last.is_a?(Symbol) == false
            INTERVAL_BASES.include?(leaf.children.last)
          end

          def calls_time?(node)
            return false unless node.body

            node.body.each_node(:send).any? do |send_node|
              send_node.method_name == :time && send_node.receiver.nil?
            end
          end
        end
      end
    end
  end
end
