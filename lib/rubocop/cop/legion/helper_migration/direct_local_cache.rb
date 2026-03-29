# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects direct calls to `Legion::Cache::Local.get` and `.set`
        # and suggests using the `local_cache_get` / `local_cache_set` helpers.
        #
        # @example
        #   # bad
        #   Legion::Cache::Local.get('key')
        #   Legion::Cache::Local.set('key', value)
        #
        #   # good
        #   local_cache_get('key')
        #   local_cache_set('key', value)
        class DirectLocalCache < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `%<helper>s` instead of `Legion::Cache::Local.%<method>s`. ' \
                'Include the appropriate local cache helper mixin.'

          RESTRICT_ON_SEND = %i[get set].freeze

          HELPER_MAP = {
            get: 'local_cache_get',
            set: 'local_cache_set'
          }.freeze

          # @!method legion_local_cache_call?(node)
          def_node_matcher :legion_local_cache_call?, <<~PATTERN
            (send (const (const (const nil? :Legion) :Cache) :Local) {:get :set} ...)
          PATTERN

          def on_send(node)
            return unless legion_local_cache_call?(node)

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
