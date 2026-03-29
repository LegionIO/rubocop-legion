# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Framework
        # Detects arithmetic subtraction on the direct return value of
        # `cache_get`. After a cache round-trip, Time objects are serialized
        # as Strings; calling `-` on a String raises NoMethodError.
        # Wrap the read with `Time.parse(val)` at cache boundaries.
        #
        # @example
        #   # bad
        #   cache_get(:last_run) - Time.now
        #
        #   # good
        #   Time.parse(cache_get(:last_run)) - Time.now
        class CacheTimeCoercion < Base
          MSG = 'Time objects become Strings after cache round-trip. ' \
                'Coerce with `Time.parse(val)` at read boundaries.'
          SEVERITY = :convention
          RESTRICT_ON_SEND = %i[-].freeze

          def on_send(node)
            receiver = node.receiver
            return unless receiver&.send_type?
            return unless receiver.receiver.nil?
            return unless receiver.method_name == :cache_get

            add_offense(node, severity: SEVERITY)
          end
        end
      end
    end
  end
end
