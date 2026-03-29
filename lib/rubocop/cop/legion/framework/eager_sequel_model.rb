# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Framework
        # Detects `class Foo < Sequel::Model(:table)` which introspects the
        # database schema at require time and will crash if the DB is unavailable.
        # Use a lazy `define_model` pattern instead.
        #
        # @example
        #   # bad
        #   class Task < Sequel::Model(:tasks)
        #   end
        #
        #   # good
        #   def self.define_task_model(db)
        #     Class.new(Sequel::Model(db[:tasks]))
        #   end
        class EagerSequelModel < Base
          MSG = 'Sequel::Model(:table) introspects schema at require time. Use a lazy define_model pattern.'
          SEVERITY = :warning

          def on_class(node)
            superclass = node.parent_class
            return unless superclass
            return unless sequel_model_with_args?(superclass)

            add_offense(superclass, severity: SEVERITY)
          end

          private

          # `class Foo < Sequel::Model(:tasks)` parses to:
          #   superclass = (send (const nil? :Sequel) :Model (sym :tasks))
          def sequel_model_with_args?(node)
            return false unless node.send_type?

            receiver = node.receiver
            return false unless receiver&.const_type?
            return false unless receiver.short_name == :Sequel

            node.method_name == :Model && node.arguments.any?
          end
        end
      end
    end
  end
end
