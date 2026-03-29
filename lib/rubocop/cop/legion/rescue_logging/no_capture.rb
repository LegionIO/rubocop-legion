# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module RescueLogging
        # Detects `rescue SomeError` where the exception class is specified but
        # no `=> e` capture is present, and auto-corrects by appending `=> e`.
        #
        # @example
        #   # bad
        #   rescue StandardError
        #     nil
        #   end
        #
        #   # bad
        #   rescue ArgumentError, TypeError
        #     nil
        #   end
        #
        #   # good
        #   rescue StandardError => e
        #     log.error(e.message)
        #   end
        class NoCapture < RuboCop::Cop::Base
          MSG = 'Exception class specified but not captured. ' \
                'Use `rescue %<classes>s => e` and log the exception.'

          def on_resbody(node)
            return if node.exceptions.empty? || !node.exception_variable.nil?
            return if rescue_modifier?(node)

            classes = node.exceptions.map(&:source).join(', ')
            message = format(MSG, classes: classes)

            add_offense(node, message: message, severity: :convention)
          end

          private

          def rescue_modifier?(node)
            rescue_node = node.parent
            return false unless rescue_node&.rescue_type?

            body = rescue_node.children.first
            body && body.source_range.line == node.loc.keyword.line
          end
        end
      end
    end
  end
end
