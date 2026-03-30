# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module HelperMigration
        # Detects direct calls to `Legion::Crypt` methods and suggests using
        # the `vault_*` helpers instead.
        #
        # @example
        #   # bad
        #   Legion::Crypt.get('secret/path')
        #   Legion::Crypt.exist?('secret/path')
        #   Legion::Crypt.write('secret/path', data)
        #
        #   # good
        #   vault_get('secret/path')
        #   vault_exist?('secret/path')
        #   vault_write('secret/path', data)
        class DirectCrypt < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Use `%<helper>s` instead of `Legion::Crypt.%<method>s`. ' \
                'Include the appropriate Vault/Crypt helper mixin.'

          RESTRICT_ON_SEND = %i[get exist? write].freeze

          HELPER_MAP = {
            get: 'vault_get',
            exist?: 'vault_exist?',
            write: 'vault_write'
          }.freeze

          # @!method legion_crypt_call?(node)
          def_node_matcher :legion_crypt_call?, <<~PATTERN
            (send (const (const nil? :Legion) :Crypt) {:get :exist? :write} ...)
          PATTERN

          def on_send(node)
            return unless legion_crypt_call?(node)

            method_name = node.method_name
            helper = HELPER_MAP[method_name]
            message = format(MSG, helper: helper, method: method_name)

            add_offense(node, message: message) do |corrector|
              args_source = node.arguments.map(&:source).join(', ')
              corrector.replace(node, "#{helper}(#{args_source})")
            end
          end
        end
      end
    end
  end
end
