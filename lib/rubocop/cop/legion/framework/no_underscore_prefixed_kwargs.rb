# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Framework
        # Bans underscore-prefixed keyword arguments and `**_rest`/`**_` splat
        # parameters in method definitions. The N×N routing design requires
        # explicit kwarg signatures: required → plain kwarg, optional → defaulted
        # kwarg, passthrough → `**opts` at the end.
        #
        # @example
        #   # bad
        #   def foo(_bar:); end
        #   def foo(**_rest); end
        #   def foo(**_); end
        #
        #   # good
        #   def foo(bar:); end
        #   def foo(bar: nil); end
        #   def foo(**opts); end
        class NoUnderscorePrefixedKwargs < Base
          extend AutoCorrector

          MSG_KWARG = 'Underscore-prefixed kwarg `%<name>s` is not allowed. ' \
                      'Use plain kwarg (required), defaulted kwarg (optional), ' \
                      'or `**opts` for passthrough.'
          MSG_SPLAT = 'Underscore-prefixed kwarg splat `%<name>s` is not allowed. ' \
                      'Use `**opts` for passthrough.'

          def on_def(node)
            check_params(node)
          end

          def on_defs(node)
            check_params(node)
          end

          private

          def check_params(method_node)
            args = method_node.arguments
            return unless args

            args.each_child_node do |arg|
              case arg.type
              when :kwarg, :kwoptarg
                check_kwarg(arg)
              when :kwrestarg
                check_kwrestarg(arg)
              end
            end
          end

          def check_kwarg(arg)
            name = arg.children.first
            return unless name.is_a?(Symbol)
            return unless name.to_s.start_with?('_')

            add_offense(arg, message: format(MSG_KWARG, name: name)) do |corrector|
              corrected = name.to_s.sub(/\A_+/, '')
              corrected = 'arg' if corrected.empty?
              corrector.replace(arg.source_range, kwarg_replacement(corrected, arg))
            end
          end

          def check_kwrestarg(arg)
            name = arg.children.first
            return unless name.is_a?(Symbol)
            return unless name.to_s.start_with?('_')

            add_offense(arg, message: format(MSG_SPLAT, name: name)) do |corrector|
              corrector.replace(arg.source_range, '**opts')
            end
          end

          def kwarg_replacement(name, arg)
            if arg.kwoptarg_type?
              default = arg.children.last
              "#{name}: #{default.source}"
            else
              "#{name}:"
            end
          end
        end
      end
    end
  end
end
