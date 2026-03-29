# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Extension::DataRequiredWithoutMigrations do
  subject(:cop) { described_class.new }

  context 'when `def self.data_required?` returns `true`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class MyExtension
          def self.data_required?
          ^^^^^^^^^^^^^^^^^^^^^^^ Legion/Extension/DataRequiredWithoutMigrations: `data_required?` returns `true`. Ensure `data/migrations/` directory exists with migration files.
            true
          end
        end
      RUBY
    end
  end

  context 'when `def self.data_required?` returns `false`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyExtension
          def self.data_required?
            false
          end
        end
      RUBY
    end
  end

  context 'when `def data_required?` (instance method) returns `true`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyExtension
          def data_required?
            true
          end
        end
      RUBY
    end
  end

  context 'when `def self.data_required?` has a complex body' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyExtension
          def self.data_required?
            ENV['RAILS_ENV'] != 'test'
          end
        end
      RUBY
    end
  end
end
