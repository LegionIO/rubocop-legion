# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Framework::SinatraHostAuth do
  subject(:cop) { described_class.new }

  it 'registers an offense for Sinatra::Base subclass without host_authorization' do
    expect_offense(<<~RUBY)
      class MyApp < Sinatra::Base
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Legion/Framework/SinatraHostAuth: Sinatra 4.0+ requires `set :host_authorization, permitted: :any` or all requests get 403.
        get '/' do
          'hello'
        end
      end
    RUBY
  end

  it 'does not register an offense when host_authorization is set' do
    expect_no_offenses(<<~RUBY)
      class MyApp < Sinatra::Base
        set :host_authorization, permitted: :any

        get '/' do
          'hello'
        end
      end
    RUBY
  end

  it 'does not register an offense for non-Sinatra class' do
    expect_no_offenses(<<~RUBY)
      class MyApp < ApplicationController
        def index
          render plain: 'hello'
        end
      end
    RUBY
  end

  it 'does not register an offense for a plain class' do
    expect_no_offenses(<<~RUBY)
      class Foo
      end
    RUBY
  end
end
