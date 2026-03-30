# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects direct calls to `Legion::Data::Connection.sequel`,
        # `Legion::Data::Local.connected?`, `Legion::Data::Local.connection`,
        # and `Legion::Data::Local.model` and suggests using the `data_connection`,
        # `local_data_connected?`, `local_data_connection`, `local_data_model`
        # helpers from `Legion::Data::Helper`.
        #
        # @example
        #   # bad
        #   Legion::Data::Connection.sequel
        #   Legion::Data::Local.connected?
        #   Legion::Data::Local.connection
        #   Legion::Data::Local.model(:traces)
        #
        #   # good
        #   data_connection
        #   local_data_connected?
        #   local_data_connection
        #   local_data_model(:traces)
        class DirectData < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `%<helper>s` instead of `%<original>s`. ' \
                'Include `Legion::Data::Helper` via the data helper mixin.'

          RESTRICT_ON_SEND = %i[sequel connected? connection model].freeze

          # @!method data_connection_sequel?(node)
          def_node_matcher :data_connection_sequel?, <<~PATTERN
            (send (const (const (const nil? :Legion) :Data) :Connection) :sequel)
          PATTERN

          # @!method data_local_call?(node)
          def_node_matcher :data_local_call?, <<~PATTERN
            (send (const (const (const nil? :Legion) :Data) :Local) {:connected? :connection :model} ...)
          PATTERN

          LOCAL_HELPER_MAP = {
            connected?: 'local_data_connected?',
            connection: 'local_data_connection',
            model: 'local_data_model'
          }.freeze

          def on_send(node)
            if data_connection_sequel?(node)
              handle_connection_sequel(node)
            elsif data_local_call?(node)
              handle_local_call(node)
            end
          end

          private

          def handle_connection_sequel(node)
            message = format(MSG, helper: 'data_connection', original: 'Legion::Data::Connection.sequel')

            add_offense(node, message: message) do |corrector|
              corrector.replace(node, 'data_connection')
            end
          end

          def handle_local_call(node)
            method_name = node.method_name
            helper = LOCAL_HELPER_MAP[method_name]
            original = "Legion::Data::Local.#{method_name}"
            message = format(MSG, helper: helper, original: original)

            add_offense(node, message: message) do |corrector|
              if node.arguments.empty?
                corrector.replace(node, helper.to_s)
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
