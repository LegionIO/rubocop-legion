# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects direct calls to `Legion::Transport::Connection` methods
        # and suggests using the `transport_*` helpers instead.
        #
        # @example
        #   # bad
        #   Legion::Transport::Connection.session_open?
        #   Legion::Transport::Connection.channel_open?
        #   Legion::Transport::Connection.lite_mode?
        #   Legion::Transport::Connection.channel
        #
        #   # good
        #   transport_session_open?
        #   transport_channel_open?
        #   transport_lite_mode?
        #   transport_channel
        class DirectTransport < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `%<helper>s` instead of `%<receiver>s.%<method>s`. ' \
                'Include the transport helper mixin.'

          RESTRICT_ON_SEND = %i[session_open? channel_open? lite_mode? channel count].freeze

          CONNECTION_MAP = {
            session_open?: 'transport_session_open?',
            channel_open?: 'transport_channel_open?',
            lite_mode?: 'transport_lite_mode?',
            channel: 'transport_channel'
          }.freeze

          SPOOL_MAP = {
            count: 'transport_spool_count'
          }.freeze

          # @!method transport_connection_call?(node)
          def_node_matcher :transport_connection_call?, <<~PATTERN
            (send (const (const (const nil? :Legion) :Transport) :Connection) {:session_open? :channel_open? :lite_mode? :channel} ...)
          PATTERN

          # @!method transport_spool_call?(node)
          def_node_matcher :transport_spool_call?, <<~PATTERN
            (send (const (const (const nil? :Legion) :Transport) :Spool) :count ...)
          PATTERN

          def on_send(node)
            if transport_connection_call?(node)
              register_offense(node, 'Legion::Transport::Connection', CONNECTION_MAP)
            elsif transport_spool_call?(node)
              register_offense(node, 'Legion::Transport::Spool', SPOOL_MAP)
            end
          end

          private

          def register_offense(node, receiver, helper_map)
            method_name = node.method_name
            helper = helper_map[method_name]
            message = format(MSG, helper: helper, receiver: receiver, method: method_name)

            add_offense(node, message: message) do |corrector|
              args_source = node.arguments.map(&:source).join(', ')
              replacement = node.arguments.empty? ? helper : "#{helper}(#{args_source})"
              corrector.replace(node, replacement)
            end
          end
        end
      end
    end
  end
end
