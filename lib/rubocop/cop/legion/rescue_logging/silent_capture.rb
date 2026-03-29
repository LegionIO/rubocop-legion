# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module RescueLogging
        # Detects `rescue => e` where the captured exception variable is never
        # referenced in the rescue body (not logged or re-raised).
        #
        # No auto-correct is provided because the fix requires semantic judgment.
        #
        # @example
        #   # bad
        #   rescue => e
        #     puts 'oops'
        #   end
        #
        #   # good
        #   rescue => e
        #     log.error(e.message)
        #   end
        #
        #   # good
        #   rescue => e
        #     raise
        #   end
        class SilentCapture < RuboCop::Cop::Base
          MSG = 'Exception captured as `%<var>s` but never logged or re-raised. ' \
                'Add `log.error(%<var>s.message)` or re-raise.'

          def on_resbody(node)
            return unless node.exception_variable

            var_name = variable_name(node.exception_variable)
            return if var_name.to_s.start_with?('_')

            body = node.body

            return if body && (references_variable?(body, var_name) || contains_raise?(body))

            add_offense(node, message: format(MSG, var: var_name), severity: :warning)
          end

          private

          def variable_name(var_node)
            var_node.name || var_node.children.first
          end

          def references_variable?(body, var_name)
            lvar_node?(body, var_name) ||
              body.each_descendant(:lvar).any? { |n| lvar_node?(n, var_name) }
          end

          def lvar_node?(node, var_name)
            node.lvar_type? && node.children.first == var_name
          end

          def contains_raise?(body)
            raise_node?(body) || body.each_descendant(:send).any? { |n| raise_node?(n) }
          end

          def raise_node?(node)
            node.send_type? && node.method_name == :raise
          end
        end
      end
    end
  end
end
