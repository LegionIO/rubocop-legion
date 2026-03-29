# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Framework
        # Detects string key access on `body` (e.g. `body['key']`).
        # `Legion::JSON.load` returns symbol keys, so string access always
        # returns nil. Auto-corrects to symbol key syntax.
        #
        # @example
        #   # bad
        #   body['data']
        #   body['complex-key']
        #
        #   # good
        #   body[:data]
        #   body[:'complex-key']
        class ApiStringKeys < Base
          extend AutoCorrector

          MSG = '`Legion::JSON.load` returns symbol keys. Use `body[:%<key>s]` instead of string keys.'
          SEVERITY = :warning
          RESTRICT_ON_SEND = %i[[]].freeze

          def on_send(node)
            receiver = node.receiver
            return unless body_receiver?(receiver)

            key_node = node.first_argument
            return unless key_node&.str_type?

            key = key_node.value
            message = format(MSG, key: key)
            add_offense(key_node, message: message, severity: SEVERITY) do |corrector|
              corrector.replace(key_node.source_range, symbol_for(key))
            end
          end

          private

          def body_receiver?(receiver)
            return false unless receiver

            send_body_receiver?(receiver) || lvar_body_receiver?(receiver)
          end

          def send_body_receiver?(receiver)
            receiver.send_type? && receiver.receiver.nil? && receiver.method_name == :body
          end

          def lvar_body_receiver?(receiver)
            receiver.lvar_type? && receiver.children.first == :body
          end

          def symbol_for(key)
            if key.match?(/\A[a-zA-Z_][a-zA-Z0-9_]*\z/)
              ":#{key}"
            else
              ":'#{key}'"
            end
          end
        end
      end
    end
  end
end
