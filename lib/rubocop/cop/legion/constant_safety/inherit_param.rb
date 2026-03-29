# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module ConstantSafety
        # Detects `const_defined?` or `const_get` called with only one argument.
        # Without `false` as the second argument, Ruby searches the entire inheritance
        # chain including `Object`, which can cause false positives and namespace leaks.
        #
        # @example
        #   # bad
        #   mod.const_defined?('Foo')
        #   mod.const_get('Bar')
        #
        #   # good
        #   mod.const_defined?('Foo', false)
        #   mod.const_get('Bar', false)
        class InheritParam < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Pass `false` as inherit parameter: `%<method>s(%<arg>s, false)`. ' \
                'Default `true` leaks through `Object`.'

          RESTRICT_ON_SEND = %i[const_defined? const_get].freeze

          def on_send(node)
            return unless node.arguments.size == 1

            arg = node.first_argument
            message = format(MSG, method: node.method_name, arg: arg.source)

            add_offense(node, message: message) do |corrector|
              corrector.insert_after(arg.source_range, ', false')
            end
          end
        end
      end
    end
  end
end
