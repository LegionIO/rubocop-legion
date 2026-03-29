# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module ConstantSafety
        # Detects bare `JSON` method calls inside `module Legion` namespaces
        # where `JSON` resolves to `Legion::JSON` instead of the stdlib.
        #
        # @example
        #   # bad (inside module Legion)
        #   module Legion
        #     JSON.parse(raw)
        #   end
        #
        #   # good
        #   module Legion
        #     ::JSON.parse(raw)
        #   end
        class BareJson < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Inside `module Legion`, bare `JSON` resolves to `Legion::JSON`. ' \
                'Use `::JSON` for stdlib.'

          RESTRICT_ON_SEND = %i[parse generate pretty_generate dump load fast_generate].freeze

          # @!method bare_json_send?(node)
          def_node_matcher :bare_json_send?, <<~PATTERN
            (send (const nil? :JSON) _ ...)
          PATTERN

          def on_send(node)
            return unless bare_json_send?(node)
            return unless inside_legion_namespace?(node)

            receiver = node.receiver
            add_offense(receiver) do |corrector|
              corrector.replace(receiver.source_range, '::JSON')
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
