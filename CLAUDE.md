# rubocop-legion

**Parent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## What is This?

Custom RuboCop plugin gem for the LegionIO ecosystem. Provides 47 AST-based cops across 6 departments. Uses the new RuboCop Plugin API (1.72+, lint_roller-based) with auto-discovery via gemspec metadata.

**GitHub**: https://github.com/LegionIO/rubocop-legion
**RubyGems**: https://rubygems.org/gems/rubocop-legion
**License**: MIT

## Shared Config Profiles

The gem ships shared `.rubocop.yml` profiles so repos don't duplicate config:

- `config/base.yml` — all shared settings (AllCops, Layout, Metrics, Style, Naming, Performance, ThreadSafety)
- `config/lex.yml` — inherits base, adds plugins (rubocop-legion + performance + thread_safety) + `ParameterLists Max: 8`
- `config/core.yml` — inherits base, adds plugins (rubocop-legion + performance + thread_safety) + `ParameterLists Max: 10, CountKeywordArgs: false`

### Bundled Plugins

Both profiles load `rubocop-performance` (52 cops) and `rubocop-thread_safety` (6 cops) as runtime dependencies. ThreadSafety defaults tuned for LegionIO: `NewThread` excludes service/connection files, `ClassInstanceVariable` excludes singletons, `RackMiddlewareInstanceVariable` disabled, `DirChdir` allows block form.

**LEX repos**: `inherit_gem: { rubocop-legion: config/lex.yml }`
**Core repos**: `inherit_gem: { rubocop-legion: config/core.yml }`

Repo-specific overrides go below the `inherit_gem` directive. Version-locked with the gem — bump gem version = all repos get updated config.

## Cop Scoping

Cops are scoped by gem type — no per-repo configuration needed:

- **Universal** (9 cops): Fire on all LegionIO gems
- **Library-specific** (6 cops): Fire on all gems but only trigger when using Sequel, Sinatra, Thor, Faraday, or cache
- **LEX-only** (31 cops): Scoped to `lib/legion/extensions/**/*.rb` via Include directive — never fire on core `legion-*` libraries

## Departments and Cops

### Universal — 10 cops

- **ConstantSafety** (4): `BareDataDefine`, `BareProcess`, `BareJson` (all error, auto-fix) — prefix with `::` inside `module Legion`. `InheritParam` (convention, auto-fix) — pass `false` to `const_defined?`/`const_get`.
- **RescueLogging** (3): `BareRescue` (warning, auto-fix) — capture with `=> e`. `NoCapture` (convention, no auto-fix) — exception class without capture. `SilentCapture` (warning, no auto-fix) — captured but never logged/re-raised. Skips `_`-prefixed vars. All skip inline rescue modifiers.
- **Singleton** (1): `UseInstance` (error, auto-fix) — `.instance` not `.new` for configurable singleton classes.
- **Framework/MutexNestedSync** (1): Nested `synchronize` blocks risk deadlock.
- **Framework/ModuleFunctionPrivate** (1): `private` after `module_function` resets visibility.

### Library-Specific — 6 cops

- `EagerSequelModel` — `Sequel::Model(:table)` at require time
- `SinatraHostAuth` — Sinatra 4.0+ `set :host_authorization`
- `ThorReservedRun` — Thor 1.5+ reserves `run`
- `FaradayXmlMiddleware` — Faraday 2.0+ removed `:xml`
- `CacheTimeCoercion` — Time→String after cache round-trip
- `ApiStringKeys` — `Legion::JSON.load` returns symbol keys (scoped to `lib/legion/extensions/**/*.rb`)

### LEX-Only — 29 cops

- **HelperMigration** (13): `DirectLogging`, `OldLoggingMethods`, `DirectJson`, `DirectCache`, `DirectLocalCache`, `DirectCrypt`, `DirectData`, `DirectLlm`, `DirectTransport`, `DirectKnowledge`, `RequireDefinedGuard` (all auto-fix) — use per-extension helpers, not global singletons. `LoggingGuard` (no auto-fix) — remove unnecessary `respond_to?(:log_warn)` / `defined?(Legion::Logging)` guards. `DefinedTransportGuard` (no auto-fix) — use `transport_connected?` instead of `defined?(Legion::Transport)`.
- **Extension** (18): `ActorSingularModule` (auto-fix), `RunnerPluralModule` (auto-fix), `CoreExtendGuard` (auto-fix), `RunnerMustBeModule`, `RunnerIncludeHelpers`, `ActorInheritance`, `EveryActorRequiresTime`, `SelfContainedActorRunnerClass`, `HookMissingRunnerClass`, `AbsorberMissingPattern`, `AbsorberMissingAbsorbMethod`, `DefinitionCallMismatched`, `RunnerReturnHash`, `SettingsKeyMethod` (auto-fix), `SettingsBracketMultiArg` (auto-fix), `LlmAskKwargs`, `ActorEnabledSideEffects`, `DataRequiredWithoutMigrations`.

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
│           ├── helper_migration/      # 13 cops (lex-only)
│           ├── constant_safety/       # 4 cops (universal)
│           ├── singleton/             # 1 cop  (universal)
│           ├── rescue_logging/        # 3 cops (universal)
│           ├── framework/             # 7 cops (universal + library-specific)
│           └── extension/             # 17 cops (lex-only)
├── config/
│   └── default.yml                    # All cop defaults, Include/Exclude scoping
└── spec/                              # mirrors lib/ structure
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
bundle exec rspec      # 350 specs
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
