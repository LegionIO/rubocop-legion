# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects `class` definitions inside a `Runners` namespace. LEX runners must
        # be modules so actors can call runner methods directly via `include` or
        # `extend self`.
        #
        # @example
        #   # bad
        #   module Runners
        #     class Foo
        #     end
        #   end
        #
        #   # good
        #   module Runners
        #     module Foo
        #     end
        #   end
        class RunnerMustBeModule < RuboCop::Cop::Base
          MSG = 'Runners must be modules, not classes. Use `module` for runner definitions.'

          def on_class(node)
            return unless inside_runners_namespace?(node)

            add_offense(node.identifier)
          end

          private

          def inside_runners_namespace?(node)
            current = node.parent
            while current
              return true if current.module_type? && (current.identifier.short_name == :Runners)

              current = current.parent
            end
            false
          end
        end
      end
    end
  end
end
