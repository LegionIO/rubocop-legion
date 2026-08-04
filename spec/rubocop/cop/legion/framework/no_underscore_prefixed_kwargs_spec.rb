# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/framework/no_underscore_prefixed_kwargs'

RSpec.describe RuboCop::Cop::Legion::Framework::NoUnderscorePrefixedKwargs, :config do
  context 'underscore-prefixed required keyword arguments' do
    it 'registers an offense for _foo: kwarg and corrects' do
      expect_offense(<<~RUBY)
        def process(_foo:)
                    ^^^^^ Underscore-prefixed kwarg `_foo` is not allowed. Use plain kwarg (required), defaulted kwarg (optional), or `**opts` for passthrough.
        end
      RUBY

      expect_correction(<<~RUBY)
        def process(foo:)
        end
      RUBY
    end

    it 'registers an offense for multiple underscore kwargs' do
      expect_offense(<<~RUBY)
        def process(_a:, _b:)
                    ^^^ Underscore-prefixed kwarg `_a` is not allowed. Use plain kwarg (required), defaulted kwarg (optional), or `**opts` for passthrough.
                         ^^^ Underscore-prefixed kwarg `_b` is not allowed. Use plain kwarg (required), defaulted kwarg (optional), or `**opts` for passthrough.
        end
      RUBY
    end

    it 'registers an offense for underscore kwarg with default and corrects' do
      expect_offense(<<~RUBY)
        def process(_foo: nil)
                    ^^^^^^^^^ Underscore-prefixed kwarg `_foo` is not allowed. Use plain kwarg (required), defaulted kwarg (optional), or `**opts` for passthrough.
        end
      RUBY

      expect_correction(<<~RUBY)
        def process(foo: nil)
        end
      RUBY
    end
  end

  context 'underscore-prefixed keyword splats' do
    it 'registers an offense for **_rest and corrects to **' do
      expect_offense(<<~RUBY)
        def process(**_rest)
                    ^^^^^^^ Underscore-prefixed splat `_rest` means unused — use `**` to accept-and-ignore, or `**opts` only if the body reads `opts`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def process(**)
        end
      RUBY
    end

    it 'registers an offense for **_ and corrects to **' do
      expect_offense(<<~RUBY)
        def process(**_)
                    ^^^ Underscore-prefixed splat `_` means unused — use `**` to accept-and-ignore, or `**opts` only if the body reads `opts`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def process(**)
        end
      RUBY
    end

    it 'registers an offense for **_opts and corrects to **' do
      expect_offense(<<~RUBY)
        def process(**_opts)
                    ^^^^^^^ Underscore-prefixed splat `_opts` means unused — use `**` to accept-and-ignore, or `**opts` only if the body reads `opts`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def process(**)
        end
      RUBY
    end
  end

  context 'mixed parameters' do
    it 'registers an offense for underscore kwarg among normal params' do
      expect_offense(<<~RUBY)
        def process(foo:, _bar:, baz: nil)
                          ^^^^^ Underscore-prefixed kwarg `_bar` is not allowed. Use plain kwarg (required), defaulted kwarg (optional), or `**opts` for passthrough.
        end
      RUBY

      expect_correction(<<~RUBY)
        def process(foo:, bar:, baz: nil)
        end
      RUBY
    end

    it 'registers an offense for underscore splat among normal params' do
      expect_offense(<<~RUBY)
        def process(foo:, **_rest)
                          ^^^^^^^ Underscore-prefixed splat `_rest` means unused — use `**` to accept-and-ignore, or `**opts` only if the body reads `opts`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def process(foo:, **)
        end
      RUBY
    end
  end

  context 'class methods' do
    it 'registers an offense for underscore kwarg in class method' do
      expect_offense(<<~RUBY)
        def self.process(_foo:)
                         ^^^^^ Underscore-prefixed kwarg `_foo` is not allowed. Use plain kwarg (required), defaulted kwarg (optional), or `**opts` for passthrough.
        end
      RUBY

      expect_correction(<<~RUBY)
        def self.process(foo:)
        end
      RUBY
    end
  end

  context 'acceptable patterns' do
    it 'does not register an offense for plain kwargs' do
      expect_no_offenses(<<~RUBY)
        def process(foo:, bar: nil)
        end
      RUBY
    end

    it 'does not register an offense for **opts splat' do
      expect_no_offenses(<<~RUBY)
        def process(**opts)
        end
      RUBY
    end

    it 'does not register an offense for **kwargs splat' do
      expect_no_offenses(<<~RUBY)
        def process(**kwargs)
        end
      RUBY
    end

    it 'does not register an offense for underscore positional args' do
      expect_no_offenses(<<~RUBY)
        def process(_unused)
        end
      RUBY
    end

    it 'does not register an offense for *args splat' do
      expect_no_offenses(<<~RUBY)
        def process(*args)
        end
      RUBY
    end

    it 'does not register an offense for block args' do
      expect_no_offenses(<<~RUBY)
        def process(&block)
        end
      RUBY
    end

    it 'does not register an offense for methods with no parameters' do
      expect_no_offenses(<<~RUBY)
        def process
        end
      RUBY
    end
  end
end
