# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects calls to `Legion::Settings.key?(:foo)` which will raise
        # `NoMethodError` because `Legion::Settings` is a module, not a Hash.
        # Auto-corrects to `!Legion::Settings[:foo].nil?`.
        #
        # @example
        #   # bad
        #   Legion::Settings.key?(:foo)
        #
        #   # good
        #   !Legion::Settings[:foo].nil?
        class SettingsKeyMethod < RuboCop::Cop::Base
          extend AutoCorrector

          RESTRICT_ON_SEND = %i[key?].freeze

          MSG = '`Legion::Settings` has no `key?` method. ' \
                'Use `!Legion::Settings[:%<key>s].nil?` instead.'

          # @!method legion_settings_key?(node)
          def_node_matcher :legion_settings_key?, <<~PATTERN
            (send
              (const (const nil? :Legion) :Settings)
              :key?
              $_)
          PATTERN

          def on_send(node)
            key_node = legion_settings_key?(node)
            return unless key_node

            key_str = source_for_key(key_node)
            message = format(MSG, key: key_str)

            add_offense(node, message: message) do |corrector|
              replacement = "!Legion::Settings[:#{key_str}].nil?"
              corrector.replace(node, replacement)
            end
          end

          private

          def source_for_key(node)
            if node.sym_type?
              node.value.to_s
            else
              node.source
            end
          end
        end
      end
    end
  end
end
