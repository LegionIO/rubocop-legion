# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Llm
        # Flags `loop do` in legion-llm production code. Unbounded loops have caused
        # runaway threads and hard-to-debug hangs. Use `N.times`, `each`, or a
        # `while` with an explicit counter instead.
        #
        # No auto-correct is provided — the fix requires choosing the correct bound.
        #
        # @example
        #   # bad
        #   loop do
        #     attempt = dispatch_request
        #     break if attempt.success?
        #   end
        #
        #   # good
        #   MAX_ATTEMPTS.times do
        #     attempt = dispatch_request
        #     break if attempt.success?
        #   end
        class NoLoopDo < Base
          MSG = '`loop do` is prohibited — use bounded iteration (`N.times`, `each`, ' \
                'or `while` with an explicit decrement) instead.'

          def on_block(node)
            return unless node.send_node.method_name == :loop
            return unless node.send_node.receiver.nil?

            add_offense(node.send_node)
          end

          alias on_numblock on_block
        end
      end
    end
  end
end
