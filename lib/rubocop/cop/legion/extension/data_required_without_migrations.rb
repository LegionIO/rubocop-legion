# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects `def self.data_required?` class methods that return `true` without
        # a corresponding `data/migrations/` directory. This is a reminder-style cop —
        # it flags the method so developers don't forget to create the migrations
        # directory.
        #
        # @example
        #   # bad (when data/migrations/ does not exist)
        #   def self.data_required?
        #     true
        #   end
        #
        #   # good
        #   def self.data_required?
        #     false
        #   end
        class DataRequiredWithoutMigrations < RuboCop::Cop::Base
          MSG = '`data_required?` returns `true`. ' \
                'Ensure `data/migrations/` directory exists with migration files.'

          def on_defs(node)
            _receiver, method_name, _args, body = *node
            return unless method_name == :data_required?
            return unless body&.true_type?

            add_offense(node)
          end
        end
      end
    end
  end
end
