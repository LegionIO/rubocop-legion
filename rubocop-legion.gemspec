# frozen_string_literal: true

require_relative 'lib/rubocop/legion/version'

Gem::Specification.new do |spec|
  spec.name          = 'rubocop-legion'
  spec.version       = RuboCop::Legion::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LegionIO code quality cops for RuboCop'
  spec.description   = 'Custom RuboCop cops for the LegionIO async job engine ecosystem. ' \
                       'Enforces helper usage, constant safety, rescue logging, framework ' \
                       'conventions, and LEX extension structure.'
  spec.homepage      = 'https://github.com/LegionIO/rubocop-legion'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.4'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/blob/main/CHANGELOG.md",
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'rubygems_mfa_required' => 'true',
    'default_lint_roller_plugin' => 'RuboCop::Legion::Plugin'
  }

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|\.github)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'lint_roller', '~> 1.1'
  spec.add_dependency 'rubocop', '>= 1.72'
  spec.add_dependency 'rubocop-ast', '>= 1.44'

  spec.add_development_dependency 'rspec', '~> 3.13'
end
