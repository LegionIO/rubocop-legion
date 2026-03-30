# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects hook classes inside a `Hooks` namespace that do not override
        # `runner_class`. Without this override, the framework hook builder dispatches
        # to nil, causing HTTP 500 errors.
        #
        # @example
        #   # bad
        #   module Hooks
        #     class Auth
        #       def handle(request)
        #         { status: 200 }
        #       end
        #     end
        #   end
        #
        #   # good
        #   module Hooks
        #     class Auth
        #       def runner_class
        #         Runners::Auth
        #       end
        #
        #       def handle(request)
        #         { status: 200 }
        #       end
        #     end
        #   end
        class HookMissingRunnerClass < RuboCop::Cop::Base
          MSG = 'Hook classes must override `runner_class`. Without it, the framework dispatches to nil.'

          def on_class(node)
            return unless inside_hooks_namespace?(node)
            return if defines_runner_class?(node)

            add_offense(node.identifier)
          end

          private

          def inside_hooks_namespace?(node)
            current = node.parent
            while current
              return true if current.module_type? && current.identifier.short_name == :Hooks

              current = current.parent
            end
            false
          end

          def defines_runner_class?(node)
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
