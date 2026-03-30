# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects direct calls to `Legion::Apollo` and `Legion::Apollo::Local`
        # methods and suggests using the `query_knowledge` / `ingest_knowledge`
        # helpers instead.
        #
        # @example
        #   # bad
        #   Legion::Apollo.query(text: 'search')
        #   Legion::Apollo.ingest(content, tags: [:foo])
        #   Legion::Apollo::Local.query(text: 'search')
        #   Legion::Apollo::Local.ingest(content)
        #
        #   # good
        #   query_knowledge(text: 'search')
        #   ingest_knowledge(content, tags: [:foo])
        #   query_knowledge(text: 'search', scope: :local)
        #   ingest_knowledge(content, scope: :local)
        class DirectKnowledge < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `%<helper>s` instead of `%<receiver>s.%<method>s`. ' \
                'Include the knowledge helper mixin.'

          RESTRICT_ON_SEND = %i[query ingest].freeze

          GLOBAL_MAP = {
            query: 'query_knowledge',
            ingest: 'ingest_knowledge'
          }.freeze

          # @!method apollo_global_call?(node)
          def_node_matcher :apollo_global_call?, <<~PATTERN
            (send (const (const nil? :Legion) :Apollo) {:query :ingest} ...)
          PATTERN

          # @!method apollo_local_call?(node)
          def_node_matcher :apollo_local_call?, <<~PATTERN
            (send (const (const (const nil? :Legion) :Apollo) :Local) {:query :ingest} ...)
          PATTERN

          def on_send(node)
            if apollo_global_call?(node)
              register_global_offense(node)
            elsif apollo_local_call?(node)
              register_local_offense(node)
            end
          end

          private

          def register_global_offense(node)
            method_name = node.method_name
            helper = GLOBAL_MAP[method_name]
            message = format(MSG, helper: helper, receiver: 'Legion::Apollo', method: method_name)

            add_offense(node, message: message) do |corrector|
              args_source = node.arguments.map(&:source).join(', ')
              corrector.replace(node, "#{helper}(#{args_source})")
            end
          end

          def register_local_offense(node)
            method_name = node.method_name
            helper = GLOBAL_MAP[method_name]
            message = format(MSG, helper: helper, receiver: 'Legion::Apollo::Local', method: method_name)

            add_offense(node, message: message) do |corrector|
              args_source = node.arguments.map(&:source).join(', ')
              scope_arg = args_source.empty? ? 'scope: :local' : "#{args_source}, scope: :local"
              corrector.replace(node, "#{helper}(#{scope_arg})")
            end
          end
        end
      end
    end
  end
end
