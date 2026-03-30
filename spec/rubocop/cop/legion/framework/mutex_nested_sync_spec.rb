# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Framework::MutexNestedSync do
  subject(:cop) { described_class.new }

  context 'when synchronize blocks are nested' do
    it 'registers an offense on the inner synchronize' do
      expect_offense(<<~RUBY)
        @mutex.synchronize do
          @other.synchronize do
          ^^^^^^^^^^^^^^^^^^ Legion/Framework/MutexNestedSync: Nested `synchronize` detected. Risk of deadlock if the same mutex is re-acquired or if lock ordering is inconsistent.
            work
          end
        end
      RUBY
    end
  end

  context 'when the same mutex is nested' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        @mutex.synchronize do
          @mutex.synchronize do
          ^^^^^^^^^^^^^^^^^^ Legion/Framework/MutexNestedSync: Nested `synchronize` detected. Risk of deadlock if the same mutex is re-acquired or if lock ordering is inconsistent.
            work
          end
        end
      RUBY
    end
  end

  context 'when synchronize blocks are deeply nested' do
    it 'registers an offense on the innermost synchronize' do
      expect_offense(<<~RUBY)
        @a.synchronize do
          @b.synchronize do
          ^^^^^^^^^^^^^^ Legion/Framework/MutexNestedSync: Nested `synchronize` detected. Risk of deadlock if the same mutex is re-acquired or if lock ordering is inconsistent.
            @c.synchronize do
            ^^^^^^^^^^^^^^ Legion/Framework/MutexNestedSync: Nested `synchronize` detected. Risk of deadlock if the same mutex is re-acquired or if lock ordering is inconsistent.
              work
            end
          end
        end
      RUBY
    end
  end

  context 'when a single synchronize block is used' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        @mutex.synchronize do
          work
        end
      RUBY
    end
  end

  context 'when synchronize blocks are sequential (not nested)' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        @mutex.synchronize do
          work_a
        end
        @other.synchronize do
          work_b
        end
      RUBY
    end
  end

  context 'when synchronize is called on a local variable' do
    it 'registers an offense when nested' do
      expect_offense(<<~RUBY)
        lock.synchronize do
          inner_lock.synchronize do
          ^^^^^^^^^^^^^^^^^^^^^^ Legion/Framework/MutexNestedSync: Nested `synchronize` detected. Risk of deadlock if the same mutex is re-acquired or if lock ordering is inconsistent.
            work
          end
        end
      RUBY
    end
  end

  context 'when synchronize uses brace block syntax' do
    it 'registers an offense when nested' do
      expect_offense(<<~RUBY)
        @mutex.synchronize {
          @other.synchronize {
          ^^^^^^^^^^^^^^^^^^ Legion/Framework/MutexNestedSync: Nested `synchronize` detected. Risk of deadlock if the same mutex is re-acquired or if lock ordering is inconsistent.
            work
          }
        }
      RUBY
    end
  end

  context 'when a non-synchronize method is nested' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        @mutex.synchronize do
          items.each do |item|
            process(item)
          end
        end
      RUBY
    end
  end
end
