# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Framework::FaradayXmlMiddleware do
  subject(:cop) { described_class.new }

  it 'registers an offense for request :xml' do
    expect_offense(<<~RUBY)
      conn.request :xml
      ^^^^^^^^^^^^^^^^^ Legion/Framework/FaradayXmlMiddleware: Faraday >= 2.0 removed built-in `:xml` middleware. Do not add it to the connection builder.
    RUBY
  end

  it 'registers an offense for response :xml' do
    expect_offense(<<~RUBY)
      conn.response :xml
      ^^^^^^^^^^^^^^^^^^ Legion/Framework/FaradayXmlMiddleware: Faraday >= 2.0 removed built-in `:xml` middleware. Do not add it to the connection builder.
    RUBY
  end

  it 'does not register an offense for request :json' do
    expect_no_offenses(<<~RUBY)
      conn.request :json
    RUBY
  end

  it 'does not register an offense for response :json' do
    expect_no_offenses(<<~RUBY)
      conn.response :json
    RUBY
  end

  it 'does not register an offense for other :xml usage' do
    expect_no_offenses(<<~RUBY)
      parse(:xml, data)
    RUBY
  end
end
