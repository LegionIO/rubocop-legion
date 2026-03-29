# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module ConstantSafety
        # Detects bare `Data.define` inside `module Legion` namespaces where it
        # resolves to `Legion::Data.define` instead of the stdlib `Data.define`.
        #
        # @example
        #   # bad (inside module Legion)
        #   module Legion
        #     Point = Data.define(:x, :y)
        #   end
        #
        #   # good
        #   module Legion
        #     Point = ::Data.define(:x, :y)
        #   end
        class BareDataDefine < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Inside `module Legion`, bare `Data.define` resolves to `Legion::Data.define`. ' \
                'Use `::Data.define`.'

          RESTRICT_ON_SEND = %i[define].freeze

          # @!method bare_data_define?(node)
          def_node_matcher :bare_data_define?, <<~PATTERN
            (send (const nil? :Data) :define ...)
          PATTERN

          def on_send(node)
            return unless bare_data_define?(node)
            return unless inside_legion_namespace?(node)

            receiver = node.receiver
            add_offense(receiver) do |corrector|
              corrector.replace(receiver.source_range, '::Data')
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
