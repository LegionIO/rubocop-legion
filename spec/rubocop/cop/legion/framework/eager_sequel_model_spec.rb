# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Framework::EagerSequelModel do
  subject(:cop) { described_class.new }

  it 'registers an offense for Sequel::Model with a table argument' do
    expect_offense(<<~RUBY)
      class Foo < Sequel::Model(:tasks)
                  ^^^^^^^^^^^^^^^^^^^^^ Legion/Framework/EagerSequelModel: Sequel::Model(:table) introspects schema at require time. Use a lazy define_model pattern.
      end
    RUBY
  end

  it 'registers an offense for Sequel::Model with a symbol argument' do
    expect_offense(<<~RUBY)
      class Bar < Sequel::Model(:accounts)
                  ^^^^^^^^^^^^^^^^^^^^^^^^ Legion/Framework/EagerSequelModel: Sequel::Model(:table) introspects schema at require time. Use a lazy define_model pattern.
      end
    RUBY
  end

  it 'does not register an offense for Sequel::Model without arguments' do
    expect_no_offenses(<<~RUBY)
      class Foo < Sequel::Model
      end
    RUBY
  end

  it 'does not register an offense for ActiveRecord::Base subclasses' do
    expect_no_offenses(<<~RUBY)
      class Foo < ActiveRecord::Base
      end
    RUBY
  end

  it 'does not register an offense for plain class definitions' do
    expect_no_offenses(<<~RUBY)
      class Foo
      end
    RUBY
  end
end
