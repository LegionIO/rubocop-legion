# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Llm
        # Validates lane field literals against the LegionIO taxonomy enums.
        # Flags `:tier`, `:type`, and `:circuit_state` literals that are not in
        # the known-valid sets, catching typos at lint time.
        #
        # `:tier` and `:circuit_state` are domain-specific keys and are always
        # validated. `:type` is only validated when it appears in a hash that
        # also contains `:tier` or `:circuit_state`, since `:type` alone is too
        # common in non-taxonomy contexts.
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
        #   { tier: :cloud, type: :inferencing }
        #
        #   # good
        #   { tier: :frontier }
        #   health[:circuit_state] = :half_open
        #   { tier: :cloud, type: :inference }
        #
        #   # ignored (`:type` alone, no taxonomy context)
        #   { type: :string }
        #   { type: :integer }
        class TaxonomyEnum < Base
          VALID_TIERS          = %i[local fleet cloud frontier direct].freeze
          VALID_TYPES          = %i[inference embedding moderation rerank image].freeze
          VALID_CIRCUIT_STATES = %i[closed open half_open].freeze

          TAXONOMY_KEYS = %i[tier type circuit_state].freeze
          CONTEXT_KEYS  = %i[tier circuit_state].freeze

          MSG_TIER    = 'Unknown tier `%<val>s`. Valid: %<valid>s.'
          MSG_TYPE    = 'Unknown type `%<val>s`. Valid: %<valid>s.'
          MSG_CIRCUIT = 'Unknown circuit_state `%<val>s`. Valid: %<valid>s.'

          def on_pair(node)
            key, value = node.children
            return unless key.sym_type? && value.sym_type?

            check_taxonomy(key.value, value, node)
          end

          def on_send(node)
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
              return if VALID_TIERS.include?(val)

              add_offense(parent_node,
                          message: format(MSG_TIER, val: val, valid: VALID_TIERS.join(', ')))
            when :type
              return if VALID_TYPES.include?(val)
              return unless taxonomy_context?(parent_node)

              add_offense(parent_node,
                          message: format(MSG_TYPE, val: val, valid: VALID_TYPES.join(', ')))
            when :circuit_state
              return if VALID_CIRCUIT_STATES.include?(val)

              add_offense(parent_node,
                          message: format(MSG_CIRCUIT, val: val, valid: VALID_CIRCUIT_STATES.join(', ')))
            end
          end

          def taxonomy_context?(pair_node)
            hash_node = pair_node.parent
            return false unless hash_node&.hash_type?

            sibling_keys = hash_node.pairs.filter_map do |pair|
              pair.key.value if pair.key.sym_type?
            end

            sibling_keys.any? { |k| CONTEXT_KEYS.include?(k) }
          end
        end
      end
    end
  end
end
