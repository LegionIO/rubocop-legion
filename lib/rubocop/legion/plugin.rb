# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module Legion
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'rubocop-legion',
          version: VERSION,
          homepage: 'https://github.com/LegionIO/rubocop-legion',
          description: 'LegionIO code quality cops for RuboCop.'
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        project_root = Pathname.new(__dir__).join('../../..')

        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: project_root.join('config', 'default.yml')
        )
      end
    end
  end
end
