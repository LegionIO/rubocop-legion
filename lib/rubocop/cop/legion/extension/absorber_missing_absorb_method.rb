# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects absorber classes inside an `Absorbers` namespace that do not define
        # the `absorb` instance method. The framework calls `absorb` when a matching
        # event arrives — without it, the absorber silently drops events.
        #
        # @example
        #   # bad
        #   module Absorbers
        #     class Foo
        #       pattern 'some.event.*'
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
        class AbsorberMissingAbsorbMethod < RuboCop::Cop::Base
          MSG = 'Absorber classes must define an `absorb` method to handle matched events.'

          def on_class(node)
            return unless inside_absorbers_namespace?(node)
            return if defines_absorb?(node)

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

          def defines_absorb?(node)
            return false unless node.body

            node.body.each_node(:def).any? do |def_node|
              def_node.method_name == :absorb
            end
          end
        end
      end
    end
  end
end
