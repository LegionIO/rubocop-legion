# frozen_string_literal: true

module RuboCop
  module Cop
    module Legion
      module Framework
        # Bans disabling `Lint/UnusedMethodArgument` with an inline directive.
        # An unused kwarg is a real offense, not something to hide — a `**` /
        # `**opts` splat already swallows extras, so the arg should be dropped;
        # if it is genuinely optional, change `**` to `**opts` and read
        # `opts[:key]`. RuboCop's own `RedundantCopDisableDirective` never flags
        # this because the offense is genuine, so the directive stays invisible.
        #
        # Autocorrect removes the directive so the real `Lint/UnusedMethodArgument`
        # offense resurfaces and must be fixed properly. It never edits the method
        # signature — dropping a load-bearing public kwarg is a human decision.
        #
        # A blanket "disable all" directive is intentionally out of scope; only
        # directives that name `Lint/UnusedMethodArgument` explicitly are flagged.
        #
        # @example
        #   # bad — a disable directive naming Lint/UnusedMethodArgument on the def
        #   def foo(bar:, unused:)
        #   end
        #
        #   # good — drop the unused arg (a splat already swallows it)
        #   def foo(bar:, **)
        #   end
        #
        #   # good — keep it and actually read it
        #   def foo(bar:, **opts)
        #     opts[:unused]
        #   end
        class NoUnusedArgDisable < Base
          include RangeHelp
          extend AutoCorrector

          MSG = 'Do not disable `Lint/UnusedMethodArgument`. Drop the unused arg ' \
                '(a `**`/`**opts` splat already swallows it) or change `**` to ' \
                '`**opts` and read `opts[:key]`.'

          TARGET = 'Lint/UnusedMethodArgument'

          # Matches a disable / todo / enable directive and captures the cop list.
          DIRECTIVE = /#\s*rubocop:(?:disable|todo|enable)\s+(?<cops>[^#]+)/

          def on_new_investigation
            processed_source.comments.each do |comment|
              match = DIRECTIVE.match(comment.text)
              next unless match

              cops = match[:cops].split(',').map(&:strip)
              next unless cops.include?(TARGET)

              register(comment, cops)
            end
          end

          private

          def register(comment, cops)
            add_offense(comment) do |corrector|
              # Only autocorrect the unambiguous single-cop case; leave multi-cop
              # directives to a human so we never strip an unrelated disable.
              corrector.remove(removal_range(comment)) if cops == [TARGET]
            end
          end

          # Trailing directive (`code # rubocop:disable ...`) → strip the comment
          # and the whitespace before it. Standalone directive line → strip the
          # whole line including its newline.
          def removal_range(comment)
            range = comment.source_range
            line_range = range.source_line
            leading = line_range[0...range.column]

            if leading.strip.empty?
              range_by_whole_lines(range, include_final_newline: true)
            else
              range.with(begin_pos: range.begin_pos - trailing_ws(leading))
            end
          end

          def trailing_ws(leading)
            leading.length - leading.rstrip.length
          end
        end
      end
    end
  end
end
