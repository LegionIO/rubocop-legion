# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Extension
        # Detects runner modules inside a `Runners` namespace that have method
        # definitions but neither `include Helpers::Lex` (or full form) nor
        # `extend self`. Without one of these, actors cannot call runner methods.
        #
        # @example
        #   # bad
        #   module Runners
        #     module Foo
        #       def run
        #         { success: true }
        #       end
        #     end
        #   end
        #
        #   # good — extend self
        #   module Runners
        #     module Foo
        #       extend self
        #
        #       def run
        #         { success: true }
        #       end
        #     end
        #   end
        #
        #   # good — include helpers
        #   module Runners
        #     module Foo
        #       include Helpers::Lex
        #
        #       def run
        #         { success: true }
        #       end
        #     end
        #   end
        class RunnerIncludeHelpers < RuboCop::Cop::Base
          MSG = 'Runner modules need `include Helpers::Lex` or `extend self` ' \
                'so actors can call methods via module.'

          def on_module(node)
            return unless inside_runners_namespace?(node)
            return unless method_definitions?(node)
            return if helpers_include?(node)
            return if extend_self?(node)

            add_offense(node.identifier)
          end

          private

          def inside_runners_namespace?(node)
            current = node.parent
            while current
              return true if current.module_type? && (current.identifier.short_name == :Runners)

              current = current.parent
            end
            false
          end

          def method_definitions?(node)
            node.body&.each_node(:def)&.any?
          end

          def helpers_include?(node)
            return false unless node.body

            node.body.each_node(:send).any? do |send_node|
              next false unless send_node.method_name == :include

              arg = send_node.arguments.first
              helpers_lex_const?(arg)
            end
          end

          def helpers_lex_const?(node)
            return false unless node&.const_type?

            name = resolve_const_name(node)
            name == 'Helpers::Lex' ||
              name == 'Legion::Extensions::Helpers::Lex' ||
              name.end_with?('::Helpers::Lex')
          end

          def extend_self?(node)
            return false unless node.body

            node.body.each_node(:send).any? do |send_node|
              send_node.method_name == :extend &&
                send_node.receiver.nil? &&
                send_node.arguments.first&.self_type?
            end
          end

          def resolve_const_name(const_node)
            parts = []
            node = const_node
            while node&.const_type?
              parts.unshift(node.short_name.to_s)
              node = node.namespace
            end
            parts.join('::')
          end
        end
      end
    end
  end
end
