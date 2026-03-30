# rubocop-legion

**Parent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## What is This?

Custom RuboCop plugin gem for the LegionIO ecosystem. Provides 32 AST-based cops across 6 departments. Uses the new RuboCop Plugin API (1.72+, lint_roller-based) with auto-discovery via gemspec metadata.

**GitHub**: https://github.com/LegionIO/rubocop-legion
**RubyGems**: https://rubygems.org/gems/rubocop-legion
**License**: MIT

## Cop Scoping

Cops are scoped by gem type — no per-repo configuration needed:

- **Universal** (9 cops): Fire on all LegionIO gems
- **Library-specific** (6 cops): Fire on all gems but only trigger when using Sequel, Sinatra, Thor, Faraday, or cache
- **LEX-only** (17 cops): Scoped to `lib/legion/extensions/**/*.rb` via Include directive — never fire on core `legion-*` libraries

## Departments and Cops

### Universal — 9 cops

- **ConstantSafety** (4): `BareDataDefine`, `BareProcess`, `BareJson` (all error, auto-fix) — prefix with `::` inside `module Legion`. `InheritParam` (convention, auto-fix) — pass `false` to `const_defined?`/`const_get`.
- **RescueLogging** (3): `BareRescue` (warning, auto-fix) — capture with `=> e`. `NoCapture` (convention, no auto-fix) — exception class without capture. `SilentCapture` (warning, no auto-fix) — captured but never logged/re-raised. Skips `_`-prefixed vars. All skip inline rescue modifiers.
- **Singleton** (1): `UseInstance` (error, auto-fix) — `.instance` not `.new` for configurable singleton classes.
- **Framework/ModuleFunctionPrivate** (1): `private` after `module_function` resets visibility.

### Library-Specific — 6 cops

- `EagerSequelModel` — `Sequel::Model(:table)` at require time
- `SinatraHostAuth` — Sinatra 4.0+ `set :host_authorization`
- `ThorReservedRun` — Thor 1.5+ reserves `run`
- `FaradayXmlMiddleware` — Faraday 2.0+ removed `:xml`
- `CacheTimeCoercion` — Time→String after cache round-trip
- `ApiStringKeys` — `Legion::JSON.load` returns symbol keys (scoped to `lib/legion/extensions/**/*.rb`)

### LEX-Only — 17 cops

- **HelperMigration** (7): `DirectLogging`, `OldLoggingMethods`, `DirectJson`, `DirectCache`, `DirectLocalCache`, `DirectCrypt` (all auto-fix) — use per-extension helpers, not global singletons. `LoggingGuard` (no auto-fix) — remove unnecessary `respond_to?(:log_warn)` / `defined?(Legion::Logging)` guards.
- **Extension** (10): `ActorSingularModule` (auto-fix), `CoreExtendGuard` (auto-fix), `RunnerMustBeModule`, `RunnerIncludeHelpers`, `SelfContainedActorRunnerClass`, `RunnerReturnHash`, `SettingsKeyMethod` (auto-fix), `SettingsBracketMultiArg` (auto-fix), `LlmAskKwargs`, `DataRequiredWithoutMigrations`.

## Architecture

```
rubocop-legion/
├── lib/
│   ├── rubocop-legion.rb              # Entry point, requires all cops
│   └── rubocop/
│       ├── legion.rb                  # Namespace declarations
│       ├── legion/
│       │   ├── version.rb
│       │   └── plugin.rb             # LintRoller::Plugin (auto-discovery)
│       └── cop/legion/
│           ├── helper_migration/      # 7 cops (lex-only)
│           ├── constant_safety/       # 4 cops (universal)
│           ├── singleton/             # 1 cop  (universal)
│           ├── rescue_logging/        # 3 cops (universal)
│           ├── framework/             # 7 cops (universal + library-specific)
│           └── extension/             # 10 cops (lex-only)
├── config/
│   └── default.yml                    # All cop defaults, Include/Exclude scoping
└── spec/                              # 233 specs, mirrors lib/ structure
```

## Key Implementation Details

- Plugin entry point: `RuboCop::Legion::Plugin` (LintRoller-based, registered via gemspec metadata `default_lint_roller_plugin`)
- All cops inherit from `RuboCop::Cop::Base`
- Auto-correctable cops use `extend AutoCorrector`
- AST matching via `def_node_matcher` and `def_node_search`
- Specs use `RuboCop::RSpec::Support` with `:config` shared context and `expect_offense`/`expect_correction`
- `BareRescue` and `NoCapture` skip rescue modifiers (inline `rescue`) to avoid syntax corruption
- `NoCapture` has no auto-correct to prevent correction loop with `Lint/UselessAssignment`
- `SilentCapture` skips `_`-prefixed variables (Ruby unused convention)

## Development

```bash
bundle install
bundle exec rspec      # 233 specs
bundle exec rubocop    # Self-linting
```

## Common Per-Repo Overrides

```yaml
# Repos using Faraday JSON middleware (string keys, not Legion::JSON symbol keys)
Legion/Framework/ApiStringKeys:
  Enabled: false
```

---

**Maintained By**: Matthew Iverson (@Esity)
