# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Llm
        # Validates lane field literals against the LegionIO taxonomy enums.
        # Flags `:tier`, `:type`, and `:circuit_state` literals that are not in
        # the known-valid sets, catching typos at lint time.
        #
        # Valid values (from Inventory::DEFAULT_PROVIDER_TIERS and the SSOT design):
        #   tier:          :local, :fleet, :cloud, :frontier, :direct
        #   type:          :inference, :embedding, :moderation, :rerank, :image
        #   circuit_state: :closed, :open, :half_open
        #
        # @example
        #   # bad  (typo)
        #   { tier: :fronteir }
        #   health[:circuit_state] = :half_opened
        #
        #   # good
        #   { tier: :frontier }
        #   health[:circuit_state] = :half_open
        class TaxonomyEnum < Base
          VALID_TIERS          = %i[local fleet cloud frontier direct].freeze
          VALID_TYPES          = %i[inference embedding moderation rerank image].freeze
          VALID_CIRCUIT_STATES = %i[closed open half_open].freeze

          MSG_TIER    = 'Unknown tier `%<val>s`. Valid: %<valid>s.'
          MSG_TYPE    = 'Unknown type `%<val>s`. Valid: %<valid>s.'
          MSG_CIRCUIT = 'Unknown circuit_state `%<val>s`. Valid: %<valid>s.'

          def on_pair(node)
            key, value = node.children
            return unless key.sym_type? && value.sym_type?

            check_taxonomy(key.value, value, node)
          end

          def on_send(node)
            # health[:circuit_state] = :bad_value
            return unless node.method_name == :[]=
            return unless node.arguments.size == 2

            key_node, val_node = node.arguments
            return unless key_node.sym_type? && val_node.sym_type?

            check_taxonomy(key_node.value, val_node, node)
          end

          private

          def check_taxonomy(key, val_node, parent_node)
            val = val_node.value
            case key
            when :tier
              unless VALID_TIERS.include?(val)
                add_offense(parent_node,
                            message: format(MSG_TIER, val: val, valid: VALID_TIERS.join(', ')))
              end
            when :type
              unless VALID_TYPES.include?(val)
                add_offense(parent_node,
                            message: format(MSG_TYPE, val: val, valid: VALID_TYPES.join(', ')))
              end
            when :circuit_state
              unless VALID_CIRCUIT_STATES.include?(val)
                msg = format(MSG_CIRCUIT, val: val, valid: VALID_CIRCUIT_STATES.join(', '))
                add_offense(parent_node, message: msg)
              end
            end
          end
        end
      end
    end
  end
end
