# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/framework/no_unused_arg_disable'

RSpec.describe RuboCop::Cop::Legion::Framework::NoUnusedArgDisable, :config do
  context 'trailing directive on a def' do
    it 'registers an offense and removes the directive' do
      expect_offense(<<~RUBY)
        def foo(bar:, unused:) # rubocop:disable Lint/UnusedMethodArgument
                               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not disable `Lint/UnusedMethodArgument`. Drop the unused arg (a `**`/`**opts` splat already swallows it) or change `**` to `**opts` and read `opts[:key]`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(bar:, unused:)
        end
      RUBY
    end
  end

  context 'rubocop:todo variant' do
    it 'registers an offense and removes the directive' do
      expect_offense(<<~RUBY)
        def foo(unused:) # rubocop:todo Lint/UnusedMethodArgument
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not disable `Lint/UnusedMethodArgument`. Drop the unused arg (a `**`/`**opts` splat already swallows it) or change `**` to `**opts` and read `opts[:key]`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(unused:)
        end
      RUBY
    end
  end

  context 'rubocop:enable variant' do
    it 'registers an offense and removes the directive' do
      expect_offense(<<~RUBY)
        # rubocop:enable Lint/UnusedMethodArgument
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not disable `Lint/UnusedMethodArgument`. Drop the unused arg (a `**`/`**opts` splat already swallows it) or change `**` to `**opts` and read `opts[:key]`.
        def foo(unused:)
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(unused:)
        end
      RUBY
    end
  end

  context 'standalone single-cop directive line' do
    it 'registers an offense and removes the whole line' do
      expect_offense(<<~RUBY)
        # rubocop:disable Lint/UnusedMethodArgument
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not disable `Lint/UnusedMethodArgument`. Drop the unused arg (a `**`/`**opts` splat already swallows it) or change `**` to `**opts` and read `opts[:key]`.
        def foo(unused:)
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(unused:)
        end
      RUBY
    end
  end

  context 'multi-cop directive naming the target' do
    it 'registers an offense but does not autocorrect' do
      expect_offense(<<~RUBY)
        def foo(unused:) # rubocop:disable Style/Documentation, Lint/UnusedMethodArgument
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not disable `Lint/UnusedMethodArgument`. Drop the unused arg (a `**`/`**opts` splat already swallows it) or change `**` to `**opts` and read `opts[:key]`.
        end
      RUBY

      expect_no_corrections
    end
  end

  context 'acceptable patterns' do
    it 'does not flag a directive for a different cop' do
      expect_no_offenses(<<~RUBY)
        def foo(bar:) # rubocop:disable Metrics/MethodLength
        end
      RUBY
    end

    it 'does not flag rubocop:disable all' do
      expect_no_offenses(<<~RUBY)
        def foo(unused:) # rubocop:disable all
        end
      RUBY
    end

    it 'does not flag a plain comment that merely mentions the cop' do
      expect_no_offenses(<<~RUBY)
        # We used to disable Lint/UnusedMethodArgument here but fixed it.
        def foo(bar:)
        end
      RUBY
    end
  end
end
