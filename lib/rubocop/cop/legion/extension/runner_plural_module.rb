# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects `module Runner` (singular) inside `Legion::Extensions::*` namespaces
        # and auto-corrects it to `module Runners` (plural), which is what the LEX
        # framework uses when discovering runner modules.
        #
        # The framework does `actor_str.sub('::Actor::', '::Runners::')` — hardcoded
        # plural. A singular `Runner` module will never be found.
        #
        # @example
        #   # bad
        #   module Legion::Extensions::Foo
        #     module Runner
        #     end
        #   end
        #
        #   # good
        #   module Legion::Extensions::Foo
        #     module Runners
        #     end
        #   end
        class RunnerPluralModule < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `module Runners` (plural), not `module Runner`. ' \
                'The framework discovers runners inside `Runners`.'

          def on_module(node)
            name_node = node.identifier
            return unless name_node.short_name == :Runner

            return unless inside_legion_extensions_namespace?(node)

            add_offense(name_node) do |corrector|
              corrector.replace(name_node.loc.name, 'Runners')
            end
          end

          private

          def inside_legion_extensions_namespace?(node)
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
