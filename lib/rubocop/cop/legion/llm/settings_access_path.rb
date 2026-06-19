# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Llm
        # Flags direct write-path access to `Legion::Settings.loader.settings[...][...]`
        # outside test files. Production code must use `Legion::Settings.dig(...)` so all
        # reads go through the typed, validated accessor.
        #
        # @example
        #   # bad
        #   Legion::Settings.loader.settings[:extensions][:llm][:default_model] = 'gemma-12b'
        #   Legion::Settings.loader.settings[:llm][:timeout]
        #
        #   # good
        #   Legion::Settings.dig(:extensions, :llm, :default_model)
        class SettingsAccessPath < Base
          MSG = 'Use `Legion::Settings.dig(...)` instead of ' \
                '`Legion::Settings.loader.settings[...][...]`.'

          def on_send(node)
            return unless loader_settings_chain?(node)

            add_offense(node)
          end

          private

          def loader_settings_chain?(node)
            return false unless %i[[] []=].include?(node.method_name)

            # For []=, the second index arg and the value are children[1] and [2]
            # The receiver of the outer []= is the inner [] node
            receiver = node.receiver
            return false unless receiver&.send_type? && receiver.method_name == :[]

            # receiver.receiver should be Legion::Settings.loader.settings
            inner = receiver.receiver
            return false unless inner&.send_type? && inner.method_name == :settings

            loader_recv = inner.receiver
            return false unless loader_recv&.send_type? && loader_recv.method_name == :loader

            settings_const?(loader_recv.receiver)
          end

          def settings_const?(node)
            return false unless node&.const_type?
            return false unless node.children.last == :Settings

            parent = node.children.first
            return true if parent.nil?
            return false unless parent.const_type? && parent.children.last == :Legion

            parent.children.first.nil?
          end
        end
      end
    end
  end
end
