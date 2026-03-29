# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Framework::ApiStringKeys do
  subject(:cop) { described_class.new }

  it 'registers an offense for body with string key and corrects to symbol' do
    expect_offense(<<~RUBY)
      body['data']
           ^^^^^^ Legion/Framework/ApiStringKeys: `Legion::JSON.load` returns symbol keys. Use `body[:data]` instead of string keys.
    RUBY

    expect_correction(<<~RUBY)
      body[:data]
    RUBY
  end

  it 'registers an offense for complex key with hyphen and corrects to quoted symbol' do
    expect_offense(<<~RUBY)
      body['complex-key']
           ^^^^^^^^^^^^^ Legion/Framework/ApiStringKeys: `Legion::JSON.load` returns symbol keys. Use `body[:complex-key]` instead of string keys.
    RUBY

    expect_correction(<<~RUBY)
      body[:'complex-key']
    RUBY
  end

  it 'does not register an offense for body with symbol key' do
    expect_no_offenses(<<~RUBY)
      body[:data]
    RUBY
  end

  it 'does not register an offense for params with string key' do
    expect_no_offenses(<<~RUBY)
      params['data']
    RUBY
  end

  it 'does not register an offense for other hash access with string key' do
    expect_no_offenses(<<~RUBY)
      hash['key']
    RUBY
  end
end
