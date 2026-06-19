# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Llm
        # Flags `handle_exception(e, level: :debug)` in rescue blocks. Exception
        # handlers must use at least `:warn` so that errors are visible in
        # production logs without enabling debug mode.
        #
        # @example
        #   # bad
        #   rescue StandardError => e
        #     handle_exception(e, level: :debug, operation: 'foo')
        #   end
        #
        #   # good
        #   rescue StandardError => e
        #     handle_exception(e, level: :warn, operation: 'foo')
        #   end
        class RescueLogLevel < Base
          MSG = '`handle_exception` called with `level: :debug` in a rescue. ' \
                'Minimum log level for exceptions is `:warn`.'

          DEBUG_LEVELS = %i[debug trace verbose].freeze

          def on_send(node)
            return unless node.method_name == :handle_exception
            return unless inside_rescue?(node)
            return unless debug_level?(node)

            add_offense(node)
          end

          private

          def debug_level?(node)
            pairs = node.arguments.flat_map do |arg|
              if arg.hash_type?
                arg.children
              elsif arg.pair_type?
                [arg]
              else
                []
              end
            end
            pairs.any? do |pair|
              key, val = pair.children
              key.sym_type? && key.value == :level &&
                val.sym_type? && DEBUG_LEVELS.include?(val.value)
            end
          end

          def inside_rescue?(node)
            node.each_ancestor(:resbody).any?
          end
        end
      end
    end
  end
end
