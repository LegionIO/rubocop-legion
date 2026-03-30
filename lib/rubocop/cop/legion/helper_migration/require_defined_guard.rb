# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects `require` or `require_relative` statements guarded by
        # `if defined?(Legion::...)`. These guards are unnecessary because
        # the framework boot sequence guarantees dependencies are loaded
        # before extensions. The guard can be safely removed.
        #
        # @example
        #   # bad
        #   require 'legion/transport/message' if defined?(Legion::Transport)
        #   require_relative 'foo/actors/bar' if defined?(Legion::Extensions::Actors::Every)
        #
        #   # good
        #   require 'legion/transport/message'
        #   require_relative 'foo/actors/bar'
        class RequireDefinedGuard < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Remove `if defined?(...)` guard from `%<method>s`. ' \
                'The framework boot sequence ensures dependencies are loaded.'

          # Match: require/require_relative 'str' if defined?(Legion::Something)
          # AST for `require 'foo' if defined?(Bar)` is:
          #   (if (defined? ...) (send nil? :require (str "...")) nil)
          def on_if(node)
            return unless modifier_if?(node)
            return unless defined_legion_guard?(node.condition)
            return unless require_call?(node.if_branch)

            method_name = node.if_branch.method_name
            add_offense(node, message: format(MSG, method: method_name)) do |corrector|
              corrector.replace(node, node.if_branch.source)
            end
          end

          private

          def modifier_if?(node)
            node.modifier_form?
          end

          def defined_legion_guard?(condition)
            return legion_defined?(condition) if condition.defined_type?

            # Handle compound: defined?(A) && defined?(B)
            if condition.and_type?
              return condition.children.any? { |child| child.defined_type? && legion_defined?(child) }
            end

            false
          end

          def legion_defined?(node)
            return false unless node.defined_type?

            child = node.children.first
            return false unless child&.const_type?

            const_source = child.source
            const_source.start_with?('Legion::')
          end

          def require_call?(node)
            return false unless node&.send_type?

            %i[require require_relative].include?(node.method_name)
          end
        end
      end
    end
  end
end
