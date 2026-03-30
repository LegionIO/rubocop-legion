# rubocop-legion

LegionIO code quality cops for [RuboCop](https://rubocop.org/).

Custom cops for the LegionIO async job engine ecosystem. Enforces helper usage, constant safety, rescue logging, framework conventions, and LEX extension structure. Replaces the regex-based `lint-patterns.yml` CI workflow with precise AST-based analysis and auto-correction.

## Installation

Add to your Gemfile:

```ruby
gem 'rubocop-legion', '~> 0.1', require: false, group: :development
```

## Usage

Use a shared config profile that includes the plugin, all standard settings, and cop defaults:

**For `lex-*` extension gems:**

```yaml
# .rubocop.yml
inherit_gem:
  rubocop-legion: config/lex.yml
```

**For `legion-*` core library gems:**

```yaml
# .rubocop.yml
inherit_gem:
  rubocop-legion: config/core.yml
```

Add repo-specific overrides below the `inherit_gem` directive. For manual setup without shared config, use `plugins: [rubocop-legion]` directly.

Requires RuboCop 1.72+ (Plugin API with lint_roller).

### What the shared configs include

Both profiles set: `TargetRubyVersion: 3.4`, `NewCops: enable`, `LineLength: 160`, `MethodLength: 50`, `ClassLength: 1500`, `ModuleLength: 1500`, `BlockLength: 40` (spec/gemspec excluded), `AbcSize: 60`, table-aligned hashes, frozen string literals, and disable `Style/Documentation`, `Naming/FileName`, `Naming/PredicateMethod`, and `Gemspec/DevelopmentDependencies`.

Both profiles also load **rubocop-performance** (52 cops) and **rubocop-thread_safety** (6 cops) as plugins. Thread safety defaults are tuned for LegionIO's concurrent architecture: `NewThread` excludes service/connection files, `ClassInstanceVariable` excludes singletons, `RackMiddlewareInstanceVariable` is disabled, `DirChdir` allows block form.

| Profile | `ParameterLists Max` | `CountKeywordArgs` |
|---------|---------------------|--------------------|
| `lex.yml` | 8 | default (true) |
| `core.yml` | 10 | false |

## Cop Scoping

Cops are automatically scoped based on where they should apply:

- **Universal cops** fire on all LegionIO gems (any code inside `module Legion`)
- **Library-specific cops** fire on all gems but only trigger when using a specific library (Sequel, Sinatra, Thor, Faraday, etc.)
- **LEX-only cops** fire only on `lib/legion/extensions/**/*.rb` — they don't apply to core `legion-*` libraries

No per-repo configuration needed for scoping. If a cop doesn't apply to your gem type, it won't fire.

## Cops

### Universal (all LegionIO gems) — 10 cops

| Department | Cop | Severity | Auto-fix | Description |
|---|---|---|---|---|
| ConstantSafety | `BareDataDefine` | error | yes | Use `::Data.define` inside `module Legion` to avoid `Legion::Data` |
| ConstantSafety | `BareProcess` | error | yes | Use `::Process` inside `module Legion` to avoid `Legion::Process` |
| ConstantSafety | `BareJson` | error | yes | Use `::JSON` inside `module Legion` to avoid `Legion::JSON` |
| ConstantSafety | `InheritParam` | convention | yes | Pass `false` to `const_defined?`/`const_get` on dynamic modules |
| RescueLogging | `BareRescue` | warning | yes | Bare `rescue` swallows exceptions — capture with `rescue => e` |
| RescueLogging | `NoCapture` | convention | no | Exception class specified but not captured (`rescue Error` without `=> e`) |
| RescueLogging | `SilentCapture` | warning | no | Captured exception never logged or re-raised |
| Singleton | `UseInstance` | error | yes | Use `.instance` instead of `.new` for singleton classes |
| Framework | `MutexNestedSync` | warning | no | Nested `synchronize` blocks risk deadlock |
| Framework | `ModuleFunctionPrivate` | convention | no | `private` after `module_function` resets visibility |

### Library-Specific (all gems, triggers on library usage) — 6 cops

| Department | Cop | Triggers on | Severity | Auto-fix | Description |
|---|---|---|---|---|---|
| Framework | `EagerSequelModel` | Sequel | warning | no | `Sequel::Model(:table)` introspects schema at require time |
| Framework | `SinatraHostAuth` | Sinatra | convention | no | Sinatra 4.0+ requires `set :host_authorization` |
| Framework | `ThorReservedRun` | Thor | warning | no | Thor 1.5+ reserves `run` — rename or use `map` |
| Framework | `FaradayXmlMiddleware` | Faraday | error | no | Faraday 2.0+ removed built-in `:xml` middleware |
| Framework | `CacheTimeCoercion` | cache_get | convention | no | Time objects become Strings after cache round-trip |
| Framework | `ApiStringKeys` | Legion::JSON.load | warning | yes | `Legion::JSON.load` returns symbol keys — use `body[:key]` |

### LEX Extensions Only (`lib/legion/extensions/**/*.rb`) — 31 cops

| Department | Cop | Severity | Auto-fix | Description |
|---|---|---|---|---|
| HelperMigration | `DirectLogging` | warning | yes | Use `log.method` instead of `Legion::Logging.method` |
| HelperMigration | `OldLoggingMethods` | warning | yes | Use `log.method` instead of deprecated `log_method` helpers |
| HelperMigration | `DirectJson` | convention | yes | Use `json_*` helpers instead of `Legion::JSON` methods |
| HelperMigration | `DirectCache` | warning | yes | Use `cache_*` helpers instead of `Legion::Cache` methods |
| HelperMigration | `DirectLocalCache` | warning | yes | Use `local_cache_*` helpers instead of `Legion::Cache::Local` methods |
| HelperMigration | `DirectCrypt` | warning | yes | Use `vault_*` helpers instead of `Legion::Crypt` methods |
| HelperMigration | `LoggingGuard` | convention | no | Remove unnecessary `respond_to?(:log_warn)` / `defined?(Legion::Logging)` guards |
| HelperMigration | `DirectData` | convention | yes | Use `data_connection`/`local_data_*` instead of `Legion::Data::Connection`/`Local` |
| HelperMigration | `DirectLlm` | convention | yes | Use `llm_*` helpers instead of `Legion::LLM` methods |
| HelperMigration | `DirectTransport` | convention | yes | Use `transport_*` helpers instead of `Legion::Transport::Connection`/`Spool` |
| HelperMigration | `DirectKnowledge` | convention | yes | Use `query_knowledge`/`ingest_knowledge` instead of `Legion::Apollo` methods |
| HelperMigration | `RequireDefinedGuard` | convention | yes | Remove `if defined?(Legion::...)` guard from `require` statements |
| HelperMigration | `DefinedTransportGuard` | convention | no | Use `transport_connected?` instead of `defined?(Legion::Transport)` |
| Extension | `ActorSingularModule` | error | yes | Use `module Actor` (singular) — framework discovers `Actor`, not `Actors` |
| Extension | `RunnerPluralModule` | error | yes | Use `module Runners` (plural) — framework discovers `Runners`, not `Runner` |
| Extension | `CoreExtendGuard` | error | yes | Guard `extend Core` with `const_defined?` for standalone compatibility |
| Extension | `RunnerMustBeModule` | warning | no | Runners must be modules, not classes |
| Extension | `RunnerIncludeHelpers` | convention | no | Runner modules need `include Helpers::Lex` or `extend self` |
| Extension | `ActorInheritance` | error | no | Actor must inherit from Every, Once, Poll, Subscription, Loop, or Nothing |
| Extension | `EveryActorRequiresTime` | warning | no | Every/Poll actors must call `time` DSL to set the interval |
| Extension | `SelfContainedActorRunnerClass` | warning | no | Self-contained actors must override `runner_class` |
| Extension | `HookMissingRunnerClass` | error | no | Hook classes must override `runner_class` |
| Extension | `AbsorberMissingPattern` | warning | no | Absorber classes must call `pattern` DSL to match events |
| Extension | `AbsorberMissingAbsorbMethod` | warning | no | Absorber classes must define `absorb` method |
| Extension | `DefinitionCallMismatched` | error | no | `definition :name` must have matching `def name` method |
| Extension | `RunnerReturnHash` | convention | no | Runner methods must return a Hash |
| Extension | `SettingsKeyMethod` | error | yes | `Legion::Settings` has no `key?` — use `!Settings[:key].nil?` |
| Extension | `SettingsBracketMultiArg` | error | yes | `Settings#[]` takes 1 arg — use `Settings.dig(...)` for nested access |
| Extension | `LlmAskKwargs` | error | no | `Legion::LLM.ask` only accepts `message:` — no extra kwargs |
| Extension | `ActorEnabledSideEffects` | convention | no | `enabled?` runs during boot — keep side-effect-free |
| Extension | `DataRequiredWithoutMigrations` | warning | no | `data_required?` returns true but migrations may be missing |

**Total: 47 custom cops** across 6 departments, 21 auto-correctable.

### Bundled Plugins

Both shared config profiles also load:

- **[rubocop-performance](https://github.com/rubocop/rubocop-performance)** — 52 cops for Ruby performance anti-patterns (all enabled)
- **[rubocop-thread_safety](https://github.com/rubocop/rubocop-thread_safety)** — 6 cops for thread safety analysis (tuned for LegionIO)

## Per-Repo Overrides

Most repos need no overrides. Common exceptions:

```yaml
# Repos using Faraday JSON middleware (string keys, not Legion::JSON symbol keys)
Legion/Framework/ApiStringKeys:
  Enabled: false
```

## License

MIT
