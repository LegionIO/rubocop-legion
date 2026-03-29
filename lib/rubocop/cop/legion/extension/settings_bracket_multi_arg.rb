# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects `Legion::Settings[:a, :b]` (2+ arguments to `[]`).
        # `Legion::Settings#[]` only accepts exactly one key; multi-key access
        # must use `Legion::Settings.dig(:a, :b)` instead.
        #
        # @example
        #   # bad
        #   Legion::Settings[:logging, :enabled]
        #
        #   # good
        #   Legion::Settings.dig(:logging, :enabled)
        class SettingsBracketMultiArg < RuboCop::Cop::Base
          extend AutoCorrector

          RESTRICT_ON_SEND = %i[[]].freeze

          MSG = '`Legion::Settings#[]` takes exactly 1 argument. ' \
                'Use `Legion::Settings.dig(...)` for nested access.'

          # @!method legion_settings_multi_bracket?(node)
          def_node_matcher :legion_settings_multi_bracket?, <<~PATTERN
            (send
              (const {nil? cbase} :Legion)
              ...
            )
          PATTERN

          def on_send(node)
            return unless node.receiver&.const_type? && node.receiver.short_name == :Settings
            return unless legion_settings_receiver_is_legion?(node.receiver)
            return if node.arguments.size < 2

            add_offense(node) do |corrector|
              args_source = node.arguments.map(&:source).join(', ')
              corrector.replace(node, "Legion::Settings.dig(#{args_source})")
            end
          end

          private

          def legion_settings_receiver_is_legion?(settings_node)
            ns = settings_node.namespace
            ns&.const_type? && ns.short_name == :Legion &&
              (ns.namespace.nil? || ns.namespace.cbase_type?)
          end
        end
      end
    end
  end
end
