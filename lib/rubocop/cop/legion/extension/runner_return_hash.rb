# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects explicit `return` of non-Hash values inside runner modules.
        # LEX runner methods must return a Hash so the framework can process
        # the result and chain tasks correctly.
        #
        # @example
        #   # bad
        #   module Runners
        #     module Foo
        #       def run
        #         return "error"
        #       end
        #     end
        #   end
        #
        #   # good
        #   module Runners
        #     module Foo
        #       def run
        #         return { success: false, message: "error" }
        #       end
        #     end
        #   end
        class RunnerReturnHash < RuboCop::Cop::Base
          MSG = 'Runner methods must return a Hash. Found explicit return of non-Hash value.'

          def on_return(node)
            return unless inside_runners_namespace?(node)
            return if node.children.empty?

            value = node.children.first
            return if value.nil?
            return if value.hash_type?

            add_offense(node)
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
