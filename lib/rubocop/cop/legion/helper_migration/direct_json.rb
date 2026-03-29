# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects direct calls to `Legion::JSON.load` and `Legion::JSON.dump`
        # and suggests using the `json_load` / `json_dump` helpers instead.
        #
        # @example
        #   # bad
        #   Legion::JSON.load(str)
        #   Legion::JSON.dump(obj)
        #
        #   # good
        #   json_load(str)
        #   json_dump(obj)
        class DirectJson < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `%<helper>s` instead of `Legion::JSON.%<method>s`. ' \
                'Include the appropriate JSON helper mixin.'

          RESTRICT_ON_SEND = %i[load dump].freeze

          HELPER_MAP = {
            load: 'json_load',
            dump: 'json_dump'
          }.freeze

          # @!method legion_json_call?(node)
          def_node_matcher :legion_json_call?, <<~PATTERN
            (send (const (const nil? :Legion) :JSON) {:load :dump} ...)
          PATTERN

          def on_send(node)
            return unless legion_json_call?(node)

            method_name = node.method_name
            helper = HELPER_MAP[method_name]
            message = format(MSG, helper: helper, method: method_name)

            add_offense(node, message: message) do |corrector|
              args_source = node.arguments.map(&:source).join(', ')
              corrector.replace(node, "#{helper}(#{args_source})")
            end
          end
        end
      end
    end
  end
end
