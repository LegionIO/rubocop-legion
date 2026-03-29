# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Framework::CacheTimeCoercion do
  subject(:cop) { described_class.new }

  it 'registers an offense for subtraction on cache_get return value' do
    expect_offense(<<~RUBY)
      cache_get(:ts) - Time.now
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/Framework/CacheTimeCoercion: Time objects become Strings after cache round-trip. Coerce with `Time.parse(val)` at read boundaries.
    RUBY
  end

  it 'registers an offense for subtraction with a different key' do
    expect_offense(<<~RUBY)
      cache_get(:last_run) - 60
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/Framework/CacheTimeCoercion: Time objects become Strings after cache round-trip. Coerce with `Time.parse(val)` at read boundaries.
    RUBY
  end

  it 'does not register an offense when cache_get result is wrapped in Time.parse' do
    expect_no_offenses(<<~RUBY)
      Time.parse(cache_get(:ts)) - Time.now
    RUBY
  end

  it 'does not register an offense for unrelated subtraction' do
    expect_no_offenses(<<~RUBY)
      foo - bar
    RUBY
  end

  it 'does not register an offense for subtraction on other method calls' do
    expect_no_offenses(<<~RUBY)
      get_value(:ts) - Time.now
    RUBY
  end
end
