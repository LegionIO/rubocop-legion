# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Legion::Framework::ThorReservedRun do
  subject(:cop) { described_class.new }

  it 'registers an offense for def run in a Thor subclass' do
    expect_offense(<<~RUBY)
      class MyCLI < Thor
        def run
        ^^^^^^^ Legion/Framework/ThorReservedRun: Thor 1.5+ reserves `run`. Use `map "run" => :method_name` or rename the method.
          do_something
        end
      end
    RUBY
  end

  it 'does not register an offense for def run outside a Thor class' do
    expect_no_offenses(<<~RUBY)
      class MyService
        def run
          do_something
        end
      end
    RUBY
  end

  it 'does not register an offense for other method names in Thor' do
    expect_no_offenses(<<~RUBY)
      class MyCLI < Thor
        def execute
          do_something
        end
      end
    RUBY
  end

  it 'does not register an offense for def run at top level' do
    expect_no_offenses(<<~RUBY)
      def run
        do_something
      end
    RUBY
  end
end
