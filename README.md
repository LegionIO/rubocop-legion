# rubocop-legion

LegionIO code quality cops for [RuboCop](https://rubocop.org/).

Custom cops for the LegionIO async job engine ecosystem. Enforces helper usage, constant safety, rescue logging, framework conventions, and LEX extension structure.

## Installation

Add to your Gemfile:

```ruby
gem 'rubocop-legion', require: false, group: :development
```

## Usage

Add to your `.rubocop.yml`:

```yaml
plugins:
  - rubocop-legion
```

## Departments

| Department | Cops | Description |
|---|---|---|
| `Legion/HelperMigration` | 6 | Use per-extension helpers, not global singletons |
| `Legion/ConstantSafety` | 4 | Prevent namespace resolution bugs inside `module Legion` |
| `Legion/Singleton` | 1 | Enforce `.instance` on singleton classes |
| `Legion/RescueLogging` | 3 | Every rescue must log or re-raise |
| `Legion/Framework` | 7 | Sequel, Sinatra, Thor, Faraday, and API gotchas |
| `Legion/Extension` | 10 | LEX structural convention enforcement |

## License

MIT
