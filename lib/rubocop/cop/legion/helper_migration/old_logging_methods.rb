# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects old bare `log_info`, `log_warn`, `log_error`, `log_debug`, `log_fatal`
        # method calls and suggests using the `log.*` helper instead.
        #
        # @example
        #   # bad
        #   log_info('hello')
        #   log_warn(msg)
        #
        #   # good
        #   log.info('hello')
        #   log.warn(msg)
        class OldLoggingMethods < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `log.%<method>s(msg)` instead of `%<old>s`. ' \
                'Include `Helpers::Lex` or `Legion::Logging::Helper`.'

          RESTRICT_ON_SEND = %i[log_info log_warn log_error log_debug log_fatal].freeze

          METHOD_MAP = {
            log_info: 'info',
            log_warn: 'warn',
            log_error: 'error',
            log_debug: 'debug',
            log_fatal: 'fatal'
          }.freeze

          # @!method old_logging_call?(node)
          def_node_matcher :old_logging_call?, <<~PATTERN
            (send nil? {:log_info :log_warn :log_error :log_debug :log_fatal} ...)
          PATTERN

          def on_send(node)
            return unless old_logging_call?(node)

            old_name = node.method_name
            new_method = METHOD_MAP[old_name]
            message = format(MSG, method: new_method, old: old_name)

            add_offense(node, message: message) do |corrector|
              args_source = node.arguments.map(&:source).join(', ')
              corrector.replace(node, "log.#{new_method}(#{args_source})")
            end
          end
        end
      end
    end
  end
end
