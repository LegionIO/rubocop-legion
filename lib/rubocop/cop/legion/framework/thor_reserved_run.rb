# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Framework
        # Detects `def run` in Thor subclasses. Thor 1.5+ reserves the `run`
        # method internally; defining it causes unexpected behavior.
        #
        # @example
        #   # bad
        #   class MyCLI < Thor
        #     def run
        #       do_something
        #     end
        #   end
        #
        #   # good
        #   class MyCLI < Thor
        #     map 'run' => :execute
        #
        #     def execute
        #       do_something
        #     end
        #   end
        class ThorReservedRun < Base
          MSG = 'Thor 1.5+ reserves `run`. Use `map "run" => :method_name` or rename the method.'
          SEVERITY = :warning

          def on_def(node)
            return unless node.method_name == :run
            return unless inside_thor_class?(node)

            add_offense(node, severity: SEVERITY)
          end

          private

          def inside_thor_class?(node)
            node.each_ancestor(:class).any? do |class_node|
              thor_class?(class_node)
            end
          end

          def thor_class?(class_node)
            superclass = class_node.parent_class
            return false unless superclass

            # Matches `Thor` or `::Thor`
            if superclass.const_type?
              superclass.short_name == :Thor
            else
              false
            end
          end
        end
      end
    end
  end
end
