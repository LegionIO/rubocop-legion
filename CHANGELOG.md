# Changelog

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
