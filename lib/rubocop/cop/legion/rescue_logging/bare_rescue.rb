# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module RescueLogging
        # Detects bare `rescue` with no exception class and no variable capture,
        # and auto-corrects by adding `=> e`.
        #
        # @example
        #   # bad
        #   begin
        #     risky
        #   rescue
        #     nil
        #   end
        #
        #   # good
        #   begin
        #     risky
        #   rescue => e
        #     log.error(e.message)
        #   end
        class BareRescue < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Bare `rescue` swallows all StandardError silently. ' \
                'Capture the exception with `rescue => e` and log it.'

          def on_resbody(node)
            return unless node.exceptions.empty? && node.exception_variable.nil?
            return if rescue_modifier?(node)

            add_offense(node, severity: :warning) do |corrector|
              corrector.insert_after(node.loc.keyword, ' => e')
            end
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
