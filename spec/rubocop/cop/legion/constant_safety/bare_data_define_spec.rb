# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/constant_safety/bare_data_define'

RSpec.describe RuboCop::Cop::Legion::ConstantSafety::BareDataDefine, :config do
  context 'inside module Legion' do
    it 'registers an offense for bare Data.define' do
      expect_offense(<<~RUBY)
        module Legion
          Point = Data.define(:x, :y)
                  ^^^^ Inside `module Legion`, bare `Data.define` resolves to `Legion::Data.define`. Use `::Data.define`.
        end
      RUBY
    end

    it 'auto-corrects to ::Data.define' do
      expect_offense(<<~RUBY)
        module Legion
          Point = Data.define(:x, :y)
                  ^^^^ Inside `module Legion`, bare `Data.define` resolves to `Legion::Data.define`. Use `::Data.define`.
        end
      RUBY

      expect_correction(<<~RUBY)
        module Legion
          Point = ::Data.define(:x, :y)
        end
      RUBY
    end

    it 'registers an offense inside a nested Legion:: namespace' do
      expect_offense(<<~RUBY)
        module Legion::Extensions::Foo
          Point = Data.define(:x, :y)
                  ^^^^ Inside `module Legion`, bare `Data.define` resolves to `Legion::Data.define`. Use `::Data.define`.
        end
      RUBY
    end

    it 'registers an offense inside a nested class inside Legion' do
      expect_offense(<<~RUBY)
        module Legion
          class MyClass
            Point = Data.define(:x, :y)
                    ^^^^ Inside `module Legion`, bare `Data.define` resolves to `Legion::Data.define`. Use `::Data.define`.
          end
        end
      RUBY
    end
  end

  context 'outside Legion namespace' do
    it 'does not register an offense for bare Data.define' do
      expect_no_offenses(<<~RUBY)
        module MyApp
          Point = Data.define(:x, :y)
        end
      RUBY
    end

    it 'does not register an offense at top level' do
      expect_no_offenses(<<~RUBY)
        Point = Data.define(:x, :y)
      RUBY
    end
  end

  context 'when already using ::Data.define inside Legion' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Legion
          Point = ::Data.define(:x, :y)
        end
      RUBY
    end
  end
end
