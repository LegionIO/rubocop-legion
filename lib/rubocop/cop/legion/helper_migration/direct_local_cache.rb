# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects direct calls to `Legion::Cache::Local` methods and suggests
        # using the `local_cache_*` helpers instead.
        #
        # @example
        #   # bad
        #   Legion::Cache::Local.get('key')
        #   Legion::Cache::Local.set('key', value)
        #   Legion::Cache::Local.delete('key')
        #   Legion::Cache::Local.fetch('key') { compute }
        #
        #   # good
        #   local_cache_get('key')
        #   local_cache_set('key', value)
        #   local_cache_delete('key')
        #   local_cache_fetch('key') { compute }
        class DirectLocalCache < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `%<helper>s` instead of `Legion::Cache::Local.%<method>s`. ' \
                'Include the appropriate local cache helper mixin.'

          RESTRICT_ON_SEND = %i[get set delete fetch].freeze

          HELPER_MAP = {
            get: 'local_cache_get',
            set: 'local_cache_set',
            delete: 'local_cache_delete',
            fetch: 'local_cache_fetch'
          }.freeze

          # @!method legion_local_cache_call?(node)
          def_node_matcher :legion_local_cache_call?, <<~PATTERN
            (send (const (const (const nil? :Legion) :Cache) :Local) {:get :set :delete :fetch} ...)
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
