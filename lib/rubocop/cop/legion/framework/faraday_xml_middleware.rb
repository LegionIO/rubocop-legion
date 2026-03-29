# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Framework
        # Detects use of the removed `:xml` middleware in Faraday connection
        # builders. Faraday >= 2.0 removed the built-in XML middleware.
        #
        # @example
        #   # bad
        #   conn = Faraday.new do |f|
        #     f.request :xml
        #     f.response :xml
        #   end
        #
        #   # good
        #   conn = Faraday.new do |f|
        #     f.request :json
        #     f.response :json
        #   end
        class FaradayXmlMiddleware < Base
          MSG = 'Faraday >= 2.0 removed built-in `:xml` middleware. Do not add it to the connection builder.'
          SEVERITY = :error
          RESTRICT_ON_SEND = %i[request response].freeze

          def on_send(node)
            return unless node.first_argument&.sym_type?
            return unless node.first_argument.value == :xml

            add_offense(node, severity: SEVERITY)
          end
        end
      end
    end
  end
end
