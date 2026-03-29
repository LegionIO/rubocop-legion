# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects `module Actors` (plural) inside `Legion::Extensions::*` namespaces
        # and auto-corrects it to `module Actor` (singular), which is what the LEX
        # framework uses when discovering actor classes.
        #
        # @example
        #   # bad
        #   module Legion::Extensions::Foo
        #     module Actors
        #     end
        #   end
        #
        #   # good
        #   module Legion::Extensions::Foo
        #     module Actor
        #     end
        #   end
        class ActorSingularModule < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `module Actor` (singular), not `module Actors`. ' \
                'The framework discovers actors inside `Actor`.'

          def on_module(node)
            name_node = node.identifier
            return unless name_node.short_name == :Actors

            return unless inside_legion_extensions_namespace?(node)

            add_offense(name_node) do |corrector|
              corrector.replace(name_node.loc.name, 'Actor')
            end
          end

          private

          def inside_legion_extensions_namespace?(node)
            # Build the full namespace path from all ancestor module/class nodes.
            # This handles both compact (`module Legion::Extensions::Foo`) and
            # nested (`module Legion; module Extensions; module Foo`) forms.
            full_path = ancestor_namespace_parts(node).join('::')
            full_path.include?('Legion') && full_path.include?('Extensions')
          end

          def ancestor_namespace_parts(node)
            parts = []
            current = node.parent
            while current
              parts.unshift(*resolve_const_parts(current.identifier)) if current.module_type? || current.class_type?
              current = current.parent
            end
            parts
          end

          def resolve_const_parts(const_node)
            parts = []
            node = const_node
            while node&.const_type?
              parts.unshift(node.short_name.to_s)
              node = node.namespace
            end
            parts
          end
        end
      end
    end
  end
end
