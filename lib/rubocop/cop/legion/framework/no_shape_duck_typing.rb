# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Framework
        # Flags `respond_to?` checks for canonical response shape methods
        # (`thinking`, `tool_calls`, `content`, `stop_reason`) and string-key
        # fallback access (`x[:k] || x['k']`). Per R10, downstream consumers
        # of canonical types should rely on the struct interface, not duck-type.
        #
        # Ships **disabled by default**. Enable per-repo or per-directory once
        # the canonical migration is complete.
        #
        # @example
        #   # bad
        #   response.respond_to?(:thinking)
        #   response.respond_to?(:tool_calls)
        #   tc[:name] || tc['name']
        #
        #   # good
        #   response.thinking
        #   response.tool_calls
        #   tc[:name]
        class NoShapeDuckTyping < Base
          MSG_RESPOND = 'Use canonical struct access instead of `respond_to?(:%<method>s)`. ' \
                        'Downstream of translators, the shape is guaranteed.'
          MSG_FALLBACK = 'String-key fallback `%<key>s` suggests duck-typed access. ' \
                         'Use canonical struct access or symbol keys consistently.'

          CANONICAL_METHODS = %w[thinking tool_calls content stop_reason].freeze

          def on_send(node)
            check_respond_to(node)
          end

          def on_or(node)
            check_string_key_fallback(node)
          end

          private

          def check_respond_to(node)
            return unless node.method_name == :respond_to?
            return unless node.arguments.length == 1

            arg = node.arguments.first
            method_name = case arg.type
                          when :sym then arg.value.to_s
                          when :str then arg.value
                          else return
                          end

            return unless CANONICAL_METHODS.include?(method_name)

            add_offense(node, message: format(MSG_RESPOND, method: method_name))
          end

          def check_string_key_fallback(node)
            left = node.children.first
            right = node.children.last
            return unless left&.send_type? && right&.send_type?
            return unless left.method_name == :[] && right.method_name == :[]

            # Both must access the same receiver
            left_recv = left.receiver
            right_recv = right.receiver
            return unless left_recv && right_recv
            return unless same_receiver?(left_recv, right_recv)

            # One must be sym, the other str
            left_key = left.arguments.first
            right_key = right.arguments.first
            return unless left_key && right_key

            has_sym = left_key.sym_type? || right_key.sym_type?
            has_str = left_key.str_type? || right_key.str_type?
            return unless has_sym && has_str

            # Extract the key name from the symbol side
            key_node = left_key.sym_type? ? left_key : right_key
            return unless key_node

            add_offense(node, message: format(MSG_FALLBACK, key: key_node.value))
          end

          def same_receiver?(left, right)
            # Both lvars with same name
            return true if left.lvar_type? && right.lvar_type? && left.children.first == right.children.first

            # Both sends with same method name and no receiver (bare identifier)
            left.send_type? && right.send_type? &&
              left.receiver.nil? && right.receiver.nil? &&
              left.method_name == right.method_name
          end
        end
      end
    end
  end
end
