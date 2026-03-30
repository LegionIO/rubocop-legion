# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects direct calls to `Legion::Cache` methods and suggests using
        # the `cache_*` helpers instead.
        #
        # @example
        #   # bad
        #   Legion::Cache.get('key')
        #   Legion::Cache.set('key', value)
        #   Legion::Cache.delete('key')
        #   Legion::Cache.fetch('key') { compute }
        #   Legion::Cache.connected?
        #
        #   # good
        #   cache_get('key')
        #   cache_set('key', value)
        #   cache_delete('key')
        #   cache_fetch('key') { compute }
        #   cache_connected?
        class DirectCache < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `%<helper>s` instead of `Legion::Cache.%<method>s`. ' \
                'Include the appropriate cache helper mixin.'

          RESTRICT_ON_SEND = %i[get set delete fetch connected?].freeze

          HELPER_MAP = {
            get: 'cache_get',
            set: 'cache_set',
            delete: 'cache_delete',
            fetch: 'cache_fetch',
            connected?: 'cache_connected?'
          }.freeze

          # @!method legion_cache_call?(node)
          def_node_matcher :legion_cache_call?, <<~PATTERN
            (send (const (const nil? :Legion) :Cache) {:get :set :delete :fetch :connected?} ...)
          PATTERN

          def on_send(node)
            return unless legion_cache_call?(node)

            method_name = node.method_name
            helper = HELPER_MAP[method_name]
            message = format(MSG, helper: helper, method: method_name)

            add_offense(node, message: message) do |corrector|
              if node.arguments.empty?
                corrector.replace(node, helper)
              else
                args_source = node.arguments.map(&:source).join(', ')
                corrector.replace(node, "#{helper}(#{args_source})")
              end
            end
          end
        end
      end
    end
  end
end
