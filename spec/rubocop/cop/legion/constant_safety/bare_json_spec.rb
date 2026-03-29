# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/constant_safety/bare_json'

RSpec.describe RuboCop::Cop::Legion::ConstantSafety::BareJson, :config do
  context 'inside module Legion' do
    it 'registers an offense for JSON.parse' do
      expect_offense(<<~RUBY)
        module Legion
          JSON.parse(raw)
          ^^^^ Inside `module Legion`, bare `JSON` resolves to `Legion::JSON`. Use `::JSON` for stdlib.
        end
      RUBY
    end

    it 'auto-corrects JSON.parse to ::JSON.parse' do
      expect_offense(<<~RUBY)
        module Legion
          JSON.parse(raw)
          ^^^^ Inside `module Legion`, bare `JSON` resolves to `Legion::JSON`. Use `::JSON` for stdlib.
        end
      RUBY

      expect_correction(<<~RUBY)
        module Legion
          ::JSON.parse(raw)
        end
      RUBY
    end

    it 'registers an offense for JSON.generate' do
      expect_offense(<<~RUBY)
        module Legion
          JSON.generate(obj)
          ^^^^ Inside `module Legion`, bare `JSON` resolves to `Legion::JSON`. Use `::JSON` for stdlib.
        end
      RUBY
    end

    it 'registers an offense for JSON.pretty_generate' do
      expect_offense(<<~RUBY)
        module Legion
          JSON.pretty_generate(obj)
          ^^^^ Inside `module Legion`, bare `JSON` resolves to `Legion::JSON`. Use `::JSON` for stdlib.
        end
      RUBY
    end

    it 'registers an offense for JSON.dump' do
      expect_offense(<<~RUBY)
        module Legion
          JSON.dump(obj)
          ^^^^ Inside `module Legion`, bare `JSON` resolves to `Legion::JSON`. Use `::JSON` for stdlib.
        end
      RUBY
    end

    it 'registers an offense for JSON.load' do
      expect_offense(<<~RUBY)
        module Legion
          JSON.load(str)
          ^^^^ Inside `module Legion`, bare `JSON` resolves to `Legion::JSON`. Use `::JSON` for stdlib.
        end
      RUBY
    end

    it 'registers an offense for JSON.fast_generate' do
      expect_offense(<<~RUBY)
        module Legion
          JSON.fast_generate(obj)
          ^^^^ Inside `module Legion`, bare `JSON` resolves to `Legion::JSON`. Use `::JSON` for stdlib.
        end
      RUBY
    end

    it 'registers an offense inside a nested Legion:: namespace' do
      expect_offense(<<~RUBY)
        module Legion::Extensions::Foo
          JSON.parse(raw)
          ^^^^ Inside `module Legion`, bare `JSON` resolves to `Legion::JSON`. Use `::JSON` for stdlib.
        end
      RUBY
    end
  end

  context 'outside Legion namespace' do
    it 'does not register an offense for bare JSON.parse' do
      expect_no_offenses(<<~RUBY)
        module MyApp
          JSON.parse(raw)
        end
      RUBY
    end

    it 'does not register an offense at top level' do
      expect_no_offenses(<<~RUBY)
        JSON.parse(raw)
      RUBY
    end
  end

  context 'when already using ::JSON inside Legion' do
    it 'does not register an offense for ::JSON.parse' do
      expect_no_offenses(<<~RUBY)
        module Legion
          ::JSON.parse(raw)
        end
      RUBY
    end

    it 'does not register an offense for ::JSON.generate' do
      expect_no_offenses(<<~RUBY)
        module Legion
          ::JSON.generate(obj)
        end
      RUBY
    end
  end
end
