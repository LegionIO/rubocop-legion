# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects `definition :method_name` DSL calls inside runner modules where
        # no corresponding `def method_name` exists. A mismatched definition means
        # the framework advertises a runner function that doesn't exist, causing
        # a NoMethodError at dispatch time.
        #
        # @example
        #   # bad
        #   module Runners
        #     module Foo
        #       definition :do_work
        #       # missing: def do_work
        #     end
        #   end
        #
        #   # good
        #   module Runners
        #     module Foo
        #       definition :do_work
        #
        #       def do_work
        #         { success: true }
        #       end
        #     end
        #   end
        class DefinitionCallMismatched < RuboCop::Cop::Base
          MSG = '`definition :%<name>s` has no matching `def %<name>s` method.'

          def on_send(node)
            return unless node.method_name == :definition
            return unless node.receiver.nil?
            return unless node.first_argument&.sym_type?

            defined_name = node.first_argument.value
            enclosing = enclosing_module_or_class(node)
            return unless enclosing
            return if defines_method?(enclosing, defined_name)

            add_offense(node, message: format(MSG, name: defined_name))
          end

          private

          def enclosing_module_or_class(node)
            current = node.parent
            while current
              return current if current.module_type? || current.class_type?

              current = current.parent
            end
            nil
          end

          def defines_method?(enclosing_node, method_name)
            return false unless enclosing_node.body

            enclosing_node.body.each_node(:def).any? do |def_node|
              def_node.method_name == method_name
            end
          end
        end
      end
    end
  end
end
