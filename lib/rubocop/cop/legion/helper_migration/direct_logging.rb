# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects direct calls to `Legion::Logging.*` and suggests using
        # the `log.*` helper instead (via `Helpers::Lex` or `Legion::Logging::Helper`).
        #
        # @example
        #   # bad
        #   Legion::Logging.info('hello')
        #   Legion::Logging.warn(msg)
        #
        #   # good
        #   log.info('hello')
        #   log.warn(msg)
        class DirectLogging < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `log.%<method>s(msg)` instead of `Legion::Logging.%<method>s`. ' \
                'Include `Helpers::Lex` or `Legion::Logging::Helper`.'

          RESTRICT_ON_SEND = %i[info warn error debug fatal].freeze

          # @!method legion_logging_call?(node)
          def_node_matcher :legion_logging_call?, <<~PATTERN
            (send (const (const nil? :Legion) :Logging) {:info :warn :error :debug :fatal} ...)
          PATTERN

          def on_send(node)
            return unless legion_logging_call?(node)

            method_name = node.method_name
            message = format(MSG, method: method_name)

            add_offense(node, message: message) do |corrector|
              args_source = node.arguments.map(&:source).join(', ')
              corrector.replace(node, "log.#{method_name}(#{args_source})")
            end
          end
        end
      end
    end
  end
end
