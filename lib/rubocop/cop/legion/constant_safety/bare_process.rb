# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module ConstantSafety
        # Detects bare `Process` method calls inside `module Legion` namespaces
        # where `Process` resolves to `Legion::Process` instead of the stdlib.
        #
        # @example
        #   # bad (inside module Legion)
        #   module Legion
        #     Process.pid
        #   end
        #
        #   # good
        #   module Legion
        #     ::Process.pid
        #   end
        class BareProcess < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Inside `module Legion`, bare `Process` resolves to `Legion::Process`. ' \
                'Use `::Process`.'

          RESTRICT_ON_SEND = %i[
            pid ppid kill detach fork wait wait2 waitpid waitpid2
            getpgid setpgid daemon exit spawn times groups
            uid gid euid egid
          ].freeze

          # @!method bare_process_send?(node)
          def_node_matcher :bare_process_send?, <<~PATTERN
            (send (const nil? :Process) _ ...)
          PATTERN

          def on_send(node)
            return unless bare_process_send?(node)
            return unless inside_legion_namespace?(node)

            receiver = node.receiver
            add_offense(receiver) do |corrector|
              corrector.replace(receiver.source_range, '::Process')
            end
          end

          private

          def inside_legion_namespace?(node)
            node.each_ancestor(:module, :class).any? do |ancestor|
              name = ancestor.identifier.source
              name == 'Legion' || name.start_with?('Legion::')
            end
          end
        end
      end
    end
  end
end
