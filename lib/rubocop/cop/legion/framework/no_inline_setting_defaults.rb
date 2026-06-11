# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Framework
        # Detects `Legion::Settings[...]` reads combined with inline literal
        # fallbacks (`|| <literal>`) or shadow-default patterns
        # (`x = N unless x.positive?`). Per G13, all defaults belong in
        # `settings.rb` — inline fallbacks are dead code after
        # `register_defaults!` merge.
        #
        # No auto-correct is provided because the fix requires moving the
        # literal into the appropriate `*_defaults` group in settings.rb.
        #
        # @example
        #   # bad
        #   max_retries = Legion::Settings[:llm][:max_retries] || 3
        #   timeout = Legion::Settings[:timeout] || 30
        #
        #   # bad (shadow default)
        #   max_retries = Legion::Settings[:llm][:max_retries]
        #   max_retries = 200 unless max_retries.positive?
        #
        #   # good
        #   max_retries = Legion::Settings[:llm][:max_retries]
        class NoInlineSettingDefaults < Base
          MSG_OR = 'Inline default `%<default>s` after `Legion::Settings` read. ' \
                   'Move the default into `settings.rb` instead.'
          MSG_SHADOW = 'Shadow-default pattern after `Legion::Settings` read. ' \
                       'Move the default into `settings.rb` instead.'

          def on_or(node)
            left = node.children.first
            right = node.children.last
            return unless settings_read?(left)
            return unless right && literal?(right)

            add_offense(node, message: format(MSG_OR, default: right.source))
          end

          def on_if(node)
            cond = node.condition
            return unless cond&.send_type?

            receiver = cond.receiver
            return unless receiver&.lvar_type?

            method_name = cond.method_name
            return unless %i[positive? nil? zero? empty? blank?].include?(method_name)

            var_name = receiver.children.first
            return unless preceded_by_settings_read?(node, var_name)

            add_offense(node, message: MSG_SHADOW)
          end

          private

          def settings_read?(node)
            return false unless node&.send_type?
            return true if direct_settings_access?(node)
            return true if nested_settings_access?(node)

            false
          end

          def direct_settings_access?(node)
            node.method_name == :[] &&
              node.receiver&.const_type? &&
              node.receiver.children.last == :Settings &&
              legion_const?(node.receiver.children.first)
          end

          def nested_settings_access?(node)
            node.method_name == :[] &&
              node.receiver&.send_type? &&
              node.receiver.method_name == :[] &&
              direct_settings_access?(node.receiver)
          end

          def legion_const?(node)
            return true if node.nil?
            return false unless node.const_type?

            node.children.last == :Legion
          end

          def literal?(node)
            %i[str int float sym].include?(node.type)
          end

          def preceded_by_settings_read?(if_node, var_name)
            parent = if_node.parent
            return false unless parent&.begin_type?

            idx = parent.children.index(if_node)
            return false unless idx&.positive?

            prev = parent.children[idx - 1]
            return false unless prev&.lvasgn_type?
            return false unless prev.children.first == var_name

            settings_read?(prev.children.last)
          end
        end
      end
    end
  end
end
