# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Framework
        # Detects modules that call both bare `module_function` and bare
        # `private`. Using `private` after `module_function` resets method
        # visibility to instance-only, which is almost never intended.
        #
        # Only bare-word forms (no arguments) are flagged. Targeted calls like
        # `module_function :foo` or `private :bar` are not flagged.
        #
        # @example
        #   # bad
        #   module Helpers
        #     module_function
        #
        #     def foo; end
        #
        #     private
        #
        #     def bar; end
        #   end
        #
        #   # good
        #   module Helpers
        #     module_function
        #
        #     def foo; end
        #   end
        class ModuleFunctionPrivate < Base
          MSG = '`private` after `module_function` resets visibility to instance-only. ' \
                'Do not use both in the same module.'
          SEVERITY = :convention

          def on_module(node)
            body = node.body
            return unless body

            bare_calls = collect_bare_visibility_calls(body)
            private_node = bare_calls[:private]
            return unless bare_calls[:module_function] && private_node

            add_offense(private_node, severity: SEVERITY)
          end

          private

          def collect_bare_visibility_calls(body)
            result = {}
            body.each_child_node do |child|
              next unless bare_visibility_call?(child)

              result[child.method_name] ||= child
            end
            result
          end

          def bare_visibility_call?(node)
            node.send_type? && node.receiver.nil? && node.arguments.empty?
          end
        end
      end
    end
  end
end
