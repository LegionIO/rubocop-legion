# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects direct calls to `Legion::JSON` methods and suggests using
        # the `json_*` helpers instead.
        #
        # @example
        #   # bad
        #   Legion::JSON.load(str)
        #   Legion::JSON.dump(obj)
        #   Legion::JSON.parse(str)
        #   Legion::JSON.generate(obj)
        #   Legion::JSON.pretty_generate(obj)
        #
        #   # good
        #   json_load(str)
        #   json_dump(obj)
        #   json_parse(str)
        #   json_generate(obj)
        #   json_pretty_generate(obj)
        class DirectJson < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `%<helper>s` instead of `Legion::JSON.%<method>s`. ' \
                'Include the appropriate JSON helper mixin.'

          RESTRICT_ON_SEND = %i[load dump parse generate pretty_generate].freeze

          HELPER_MAP = {
            load: 'json_load',
            dump: 'json_dump',
            parse: 'json_parse',
            generate: 'json_generate',
            pretty_generate: 'json_pretty_generate'
          }.freeze

          # @!method legion_json_call?(node)
          def_node_matcher :legion_json_call?, <<~PATTERN
            (send (const (const nil? :Legion) :JSON) {:load :dump :parse :generate :pretty_generate} ...)
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
