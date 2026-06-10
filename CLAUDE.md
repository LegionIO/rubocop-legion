# rubocop-legion

Custom RuboCop plugin gem for the LegionIO ecosystem. Provides 47 AST-based cops across 6 departments. Uses the RuboCop Plugin API (1.72+, lint_roller-based) with auto-discovery via gemspec metadata.

## Shared Config Profiles

- `config/base.yml` — all shared settings (AllCops, Layout, Metrics, Style, Naming, Performance, ThreadSafety)
- `config/lex.yml` — inherits base, adds plugins + `ParameterLists Max: 8`
- `config/core.yml` — inherits base, adds plugins + `ParameterLists Max: 10, CountKeywordArgs: false`

Both profiles load `rubocop-performance` (52 cops) and `rubocop-thread_safety` (6 cops) as runtime dependencies.

**LEX repos**: `inherit_gem: { rubocop-legion: config/lex.yml }`
**Core repos**: `inherit_gem: { rubocop-legion: config/core.yml }`

## Cop Departments

| Department | Count | Scope |
|------------|-------|-------|
| ConstantSafety | 4 | Universal |
| RescueLogging | 3 | Universal |
| Singleton | 1 | Universal |
| Framework | 8 | Universal + Library-specific |
| HelperMigration | 13 | LEX-only |
| Extension | 18 | LEX-only |

Cops are scoped by gem type — no per-repo configuration needed. LEX-only cops fire on `lib/legion/extensions/**/*.rb` via Include directive.

## Architecture

```
rubocop-legion/
├── lib/
│   ├── rubocop-legion.rb              # Entry point
│   └── rubocop/
│       ├── legion/
│       │   └── plugin.rb             # LintRoller::Plugin (auto-discovery)
│       └── cop/legion/
│           ├── helper_migration/      # 13 cops (lex-only)
│           ├── constant_safety/       # 4 cops (universal)
│           ├── singleton/             # 1 cop  (universal)
│           ├── rescue_logging/        # 3 cops (universal)
│           ├── framework/             # 8 cops (universal + library-specific)
│           └── extension/             # 18 cops (lex-only)
├── config/
│   └── default.yml                    # All cop defaults, Include/Exclude scoping
└── spec/                              # mirrors lib/ structure
```

## Development

```bash
bundle install
bundle exec rspec      # 350 specs
bundle exec rubocop    # Self-linting
```
