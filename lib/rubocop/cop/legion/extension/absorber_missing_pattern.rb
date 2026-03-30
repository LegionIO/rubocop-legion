# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects absorber classes inside an `Absorbers` namespace that do not call
        # the `pattern` DSL method. Without `pattern`, the absorber will not match
        # any events and will be silently inactive.
        #
        # @example
        #   # bad
        #   module Absorbers
        #     class Foo
        #       def absorb(event)
        #         process(event)
        #       end
        #     end
        #   end
        #
        #   # good
        #   module Absorbers
        #     class Foo
        #       pattern 'some.event.*'
        #
        #       def absorb(event)
        #         process(event)
        #       end
        #     end
        #   end
        class AbsorberMissingPattern < RuboCop::Cop::Base
          MSG = 'Absorber classes must call the `pattern` DSL method to match events.'

          def on_class(node)
            return unless inside_absorbers_namespace?(node)
            return if calls_pattern?(node)

            add_offense(node.identifier)
          end

          private

          def inside_absorbers_namespace?(node)
            current = node.parent
            while current
              return true if current.module_type? && current.identifier.short_name == :Absorbers

              current = current.parent
            end
            false
          end

          def calls_pattern?(node)
            return false unless node.body

            node.body.each_node(:send).any? do |send_node|
              send_node.method_name == :pattern && send_node.receiver.nil?
            end
          end
        end
      end
    end
  end
end
