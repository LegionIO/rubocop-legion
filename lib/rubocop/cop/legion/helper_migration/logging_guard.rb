# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects unnecessary guard checks around logging that are no longer
        # needed. The `log` helper is always available in extensions via
        # `Helpers::Lex`.
        #
        # Catches two patterns:
        # 1. `respond_to?` checks for old logging methods or `log`
        # 2. `defined?(Legion::Logging)` guards
        #
        # @example
        #   # bad
        #   log.warn(msg) if respond_to?(:log_warn, true)
        #   log.info(msg) if respond_to?(:log)
        #   Legion::Logging.info(msg) if defined?(Legion::Logging)
        #
        #   # good
        #   log.warn(msg)
        #   log.info(msg)
        class LoggingGuard < RuboCop::Cop::Base
          MSG_RESPOND_TO = '`respond_to?(:%<method>s)` guard is unnecessary. ' \
                           '`log` is always available via `Helpers::Lex`.'
          MSG_DEFINED = '`defined?(Legion::Logging)` guard is unnecessary. ' \
                        '`Legion::Logging` is always loaded in the framework.'

          OLD_METHODS = %i[log log_info log_warn log_error log_debug log_fatal].to_set.freeze

          RESTRICT_ON_SEND = %i[respond_to?].freeze

          # respond_to?(:log_warn) or respond_to?(:log_warn, true)
          # @!method old_logging_respond_to?(node)
          def_node_matcher :old_logging_respond_to?, <<~PATTERN
            (send nil? :respond_to? (sym $_) ...)
          PATTERN

          def on_send(node)
            old_logging_respond_to?(node) do |method_name|
              next unless OLD_METHODS.include?(method_name)

              add_offense(node, message: format(MSG_RESPOND_TO, method: method_name))
            end
          end

          # defined? is a keyword, not a send — handle via on_defined? callback
          def on_defined?(node)
            return false unless legion_logging_defined?(node)

            add_offense(node, message: MSG_DEFINED)
          end

          private

          def legion_logging_defined?(node)
            child = node.children.first
            return false unless child&.const_type?

            # Match Legion::Logging — (const (const nil :Legion) :Logging)
            parent_const = child.children.first
            parent_const&.const_type? &&
              parent_const.children == [nil, :Legion] &&
              child.children.last == :Logging
          end
        end
      end
    end
  end
end
