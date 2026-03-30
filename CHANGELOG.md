# Changelog

## [0.1.7] - 2026-03-29

### Added
- New cop `Legion/HelperMigration/DirectTransport`: use `transport_*` helpers instead of `Legion::Transport::Connection`/`Spool` methods (auto-fix)
- New cop `Legion/HelperMigration/DirectKnowledge`: use `query_knowledge`/`ingest_knowledge` helpers instead of `Legion::Apollo`/`Legion::Apollo::Local` methods (auto-fix)

### Changed
- Renamed `Legion/HelperMigration/DirectLlmEmbed` to `Legion/HelperMigration/DirectLlm` — now covers `chat`, `ask`, `structured`, `embed_batch` in addition to `embed`
- Expanded `Legion/HelperMigration/DirectJson` to cover `parse`, `generate`, `pretty_generate`
- Expanded `Legion/HelperMigration/DirectCache` to cover `fetch`, `connected?`
- Expanded `Legion/HelperMigration/DirectLocalCache` to cover `delete`, `fetch`
- Expanded `Legion/HelperMigration/DirectCrypt` to cover `write`

## [0.1.6] - 2026-03-29

### Added
- Bundled `rubocop-performance` (52 cops) — Ruby performance anti-pattern detection, all enabled by default
- Bundled `rubocop-thread_safety` (6 cops) — thread safety analysis for concurrent code
- Tuned ThreadSafety defaults: `NewThread` excludes service/connection files, `ClassInstanceVariable` excludes singletons, `RackMiddlewareInstanceVariable` disabled, `DirChdir` allows block form

## [0.1.5] - 2026-03-29

### Added
- New cop `Legion/Framework/MutexNestedSync`: detect nested `synchronize` blocks (deadlock risk)
- New cop `Legion/Extension/ActorEnabledSideEffects`: flag `enabled?` in actor classes that runs during boot (keep side-effect-free)

## [0.1.4] - 2026-03-29

### Added
- New cop `Legion/HelperMigration/DirectData`: use `data_connection`/`local_data_*` helpers instead of `Legion::Data::Connection`/`Legion::Data::Local` (auto-fix)
- New cop `Legion/HelperMigration/DirectLlmEmbed`: use `llm_embed` helper instead of `Legion::LLM.embed` (auto-fix)
- New cop `Legion/HelperMigration/RequireDefinedGuard`: remove `if defined?(Legion::...)` from require statements (auto-fix)
- New cop `Legion/HelperMigration/DefinedTransportGuard`: use `transport_connected?` instead of `defined?(Legion::Transport)`
- New cop `Legion/Extension/RunnerPluralModule`: enforce `module Runners` (plural), auto-correctable
- New cop `Legion/Extension/ActorInheritance`: actor must inherit from Every, Once, Poll, Subscription, Loop, or Nothing
- New cop `Legion/Extension/EveryActorRequiresTime`: Every/Poll actors must call `time` DSL
- New cop `Legion/Extension/HookMissingRunnerClass`: hook classes must override `runner_class`
- New cop `Legion/Extension/AbsorberMissingPattern`: absorber classes must call `pattern` DSL
- New cop `Legion/Extension/AbsorberMissingAbsorbMethod`: absorber classes must define `absorb` method
- New cop `Legion/Extension/DefinitionCallMismatched`: `definition :name` must have matching `def name`

## [0.1.3] - 2026-03-29

### Added
- Shared config profiles: `config/lex.yml` for lex-* gems, `config/core.yml` for legion-* gems
- Use `inherit_gem: { rubocop-legion: config/lex.yml }` to replace 60-line .rubocop.yml with 2 lines

## [0.1.2] - 2026-03-29

### Added
- New cop `Legion/HelperMigration/LoggingGuard`: flags unnecessary `respond_to?(:log_warn)` etc. and `defined?(Legion::Logging)` guards

## [0.1.1] - 2026-03-29

### Fixed
- BareRescue auto-corrector no longer corrupts inline rescue modifiers (`foo rescue nil`)
- NoCapture removed auto-correct to prevent correction loop with Lint/UselessAssignment
- SilentCapture skips `_`-prefixed variables (Ruby unused variable convention)

### Changed
- HelperMigration cops scoped to `lib/legion/extensions/**/*.rb` (lex-* gems only)
- Extension cops scoped to `lib/legion/extensions/**/*.rb` with spec exclusion
- ApiStringKeys scoped to `lib/legion/extensions/**/*.rb` (Faraday responses use string keys)

## [0.1.0] - 2026-03-29

### Added
- Initial release with 31 cops across 6 departments
- New RuboCop Plugin API (1.72+, lint_roller based)
- **Legion/HelperMigration** (6 cops): enforce `log.method`, `json_load`/`json_dump`, `cache_get`/`cache_set`, `vault_get`/`vault_exist?` helpers over direct singleton calls. All auto-correctable.
- **Legion/ConstantSafety** (4 cops): prevent `Data.define`, `Process`, `JSON` namespace resolution bugs inside `module Legion`; enforce `const_defined?(name, false)`. All auto-correctable.
- **Legion/Singleton** (1 cop): enforce `.instance` over `.new` for configurable list of singleton classes. Auto-correctable.
- **Legion/RescueLogging** (3 cops): require rescue blocks to capture exceptions and log or re-raise them. Partial auto-correct (adds `=> e` capture).
- **Legion/Framework** (7 cops): catch Sequel eager model loading, Sinatra 4.0 host auth, Thor reserved `run`, Faraday XML middleware removal, `module_function`+`private` conflict, cache time coercion, API string keys. `ApiStringKeys` auto-correctable.
- **Legion/Extension** (10 cops): enforce LEX structural conventions — `module Actor` singular, `extend Core` guard, runner module structure, self-contained actor `runner_class`, `Settings` API correctness, `LLM.ask` signature, `data_required?` migration check. 4 auto-correctable.
