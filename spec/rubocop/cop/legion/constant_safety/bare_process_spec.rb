# frozen_string_literal: true

require 'spec_helper'
require 'rubocop/cop/legion/constant_safety/bare_process'

RSpec.describe RuboCop::Cop::Legion::ConstantSafety::BareProcess, :config do
  context 'inside module Legion' do
    it 'registers an offense for Process.pid' do
      expect_offense(<<~RUBY)
        module Legion
          Process.pid
          ^^^^^^^ Inside `module Legion`, bare `Process` resolves to `Legion::Process`. Use `::Process`.
        end
      RUBY
    end

    it 'auto-corrects Process.pid to ::Process.pid' do
      expect_offense(<<~RUBY)
        module Legion
          Process.pid
          ^^^^^^^ Inside `module Legion`, bare `Process` resolves to `Legion::Process`. Use `::Process`.
        end
      RUBY

      expect_correction(<<~RUBY)
        module Legion
          ::Process.pid
        end
      RUBY
    end

    it 'registers an offense for Process.kill' do
      expect_offense(<<~RUBY)
        module Legion
          Process.kill('TERM', 42)
          ^^^^^^^ Inside `module Legion`, bare `Process` resolves to `Legion::Process`. Use `::Process`.
        end
      RUBY
    end

    it 'registers an offense for Process.exit' do
      expect_offense(<<~RUBY)
        module Legion
          Process.exit(1)
          ^^^^^^^ Inside `module Legion`, bare `Process` resolves to `Legion::Process`. Use `::Process`.
        end
      RUBY
    end

    it 'registers an offense for Process.ppid' do
      expect_offense(<<~RUBY)
        module Legion
          Process.ppid
          ^^^^^^^ Inside `module Legion`, bare `Process` resolves to `Legion::Process`. Use `::Process`.
        end
      RUBY
    end

    it 'registers an offense inside a nested Legion:: namespace' do
      expect_offense(<<~RUBY)
        module Legion::Extensions::Foo
          Process.pid
          ^^^^^^^ Inside `module Legion`, bare `Process` resolves to `Legion::Process`. Use `::Process`.
        end
      RUBY
    end
  end

  context 'outside Legion namespace' do
    it 'does not register an offense for bare Process.pid' do
      expect_no_offenses(<<~RUBY)
        module MyApp
          Process.pid
        end
      RUBY
    end

    it 'does not register an offense at top level' do
      expect_no_offenses(<<~RUBY)
        Process.pid
      RUBY
    end
  end

  context 'when already using ::Process inside Legion' do
    it 'does not register an offense for ::Process.pid' do
      expect_no_offenses(<<~RUBY)
        module Legion
          ::Process.pid
        end
      RUBY
    end

    it 'does not register an offense for ::Process.kill' do
      expect_no_offenses(<<~RUBY)
        module Legion
          ::Process.kill('TERM', 42)
        end
      RUBY
    end
  end
end
