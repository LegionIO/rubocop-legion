# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Framework
        # Detects Sinatra::Base subclasses that do not call
        # `set :host_authorization`. Sinatra 4.0+ rejects all requests without
        # this configuration, returning HTTP 403.
        #
        # @example
        #   # bad
        #   class MyApp < Sinatra::Base
        #     get '/' do
        #       'hello'
        #     end
        #   end
        #
        #   # good
        #   class MyApp < Sinatra::Base
        #     set :host_authorization, permitted: :any
        #
        #     get '/' do
        #       'hello'
        #     end
        #   end
        class SinatraHostAuth < Base
          MSG = 'Sinatra 4.0+ requires `set :host_authorization, permitted: :any` or all requests get 403.'
          SEVERITY = :convention

          def on_class(node)
            return unless sinatra_base_subclass?(node)
            return if body_sets_host_authorization?(node)

            add_offense(node, severity: SEVERITY)
          end

          private

          def sinatra_base_subclass?(node)
            superclass = node.parent_class
            return false unless superclass&.const_type?

            superclass.namespace&.const_type? &&
              superclass.namespace.short_name == :Sinatra &&
              superclass.short_name == :Base
          end

          def body_sets_host_authorization?(node)
            body = node.body
            return false unless body

            body.each_descendant(:send).any? do |send_node|
              send_node.receiver.nil? &&
                send_node.method_name == :set &&
                send_node.first_argument&.sym_type? &&
                send_node.first_argument.value == :host_authorization
            end
          end
        end
      end
    end
  end
end
