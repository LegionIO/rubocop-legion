# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Singleton
        # Detects `.new` calls on singleton classes and auto-corrects to `.instance`.
        #
        # @example
        #   # bad
        #   TokenCache.new
        #   Registry.new(arg)
        #
        #   # good
        #   TokenCache.instance
        #   Registry.instance
        class UseInstance < RuboCop::Cop::Base
          extend AutoCorrector

          RESTRICT_ON_SEND = %i[new].freeze

          MSG = 'Use `%<class_name>s.instance` instead of `.new` for singleton classes.'

          def on_send(node)
            receiver = node.receiver
            return unless receiver&.const_type?

            class_name = receiver.children.last.to_s
            return unless singleton_classes.include?(class_name)

            message = format(MSG, class_name: class_name)
            add_offense(node, message: message, severity: :error) do |corrector|
              # Replace the entire send expression: Receiver.new(args) -> Receiver.instance
              corrector.replace(node, "#{class_name}.instance")
            end
          end

          private

          def singleton_classes
            cop_config.fetch('SingletonClasses', %w[TokenCache Registry Catalog])
          end
        end
      end
    end
  end
end
