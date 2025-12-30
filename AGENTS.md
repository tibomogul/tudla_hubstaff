# AGENTS.md

Guidelines for AI agents working on this codebase.

## Project Overview

**TudlaHubstaff** is a Rails 8.1 mountable engine gem that provides core domain logic with the "Solid trifecta" integration:
- **Solid Queue** - Background job processing
- **Solid Cache** - SQL-backed caching
- **Solid Cable** - Action Cable adapter

Additional integrations: Tailwind CSS, Importmap Rails.

## Architecture

```
tudla_hubstaff/
├── app/                    # Engine application code (controllers, models, views, jobs)
├── config/                 # Engine configuration
├── lib/
│   ├── tudla_hubstaff.rb        # Main entry point, requires dependencies
│   └── tudla_hubstaff/
│       ├── engine.rb       # Rails::Engine configuration
│       └── version.rb      # Gem version
├── spec/
│   ├── dummy/              # Full Rails app for testing the engine
│   ├── integration/        # Integration specs
│   ├── rails_helper.rb     # RSpec Rails configuration
│   └── spec_helper.rb      # RSpec base configuration
└── tudla_hubstaff.gemspec       # Gem specification
```

## Key Conventions

### Engine Isolation
- The engine uses `isolate_namespace TudlaHubstaff` - all models, controllers, and routes are namespaced under `TudlaHubstaff::`
- URL helpers require `TudlaHubstaff::Engine.routes.url_helpers`

### Database Configuration (Solid Trifecta)
The dummy app uses **multiple databases** for the Solid stack:
- `primary` - Main application database
- `queue` - Solid Queue tables
- `cache` - Solid Cache tables  
- `cable` - Solid Cable tables

**Important:** Each Solid gem requires `connects_to` configuration in the environment file:
```ruby
config.solid_queue.connects_to = { database: { writing: :queue } }
config.solid_cache.connects_to = { database: { writing: :cache } }
```

Do NOT use both `database:` in yml config files AND `connects_to` in environment config - they conflict.

### Testing

- **Framework:** RSpec with FactoryBot
- **Test app:** `spec/dummy/` is a full Rails application
- **Run tests:** `bundle exec rspec`
- **Coverage:** SimpleCov enabled

When writing tests:
- Use `stub_const` for inline job classes (SolidQueue requires named classes)
- SolidCache hashes keys internally - don't query by raw key name
- Include `TudlaHubstaff::Engine.routes.url_helpers` for route helpers in specs

### Code Style

- **Linting:** RuboCop with `rubocop-rails-omakase` (Rails default style)
- **Ruby version:** See `.ruby-version`

### Dependencies

Runtime dependencies (from gemspec):
- `rails >= 8.1.1`
- `solid_queue`, `solid_cache`, `solid_cable`
- `tailwindcss-rails`, `importmap-rails`

Development dependencies:
- `rspec-rails`, `factory_bot_rails`, `capybara`
- `sqlite3` (test database)
- `simplecov` (coverage)

## Common Tasks

```bash
# Run all specs
bundle exec rspec

# Run specific spec file
bundle exec rspec spec/integration/solid_stack_spec.rb

# Run migrations (delegated to dummy app)
bundle exec rails db:migrate

# Prepare test databases
cd spec/dummy && RAILS_ENV=test bin/rails db:prepare

# Run RuboCop
bundle exec rubocop
```

## Gotchas

1. **Solid gems and database connections** - Always configure `connects_to` in environment files, not `database:` in yml files for dev/test
2. **Engine routes** - Use `main_app.` prefix for host app routes, engine routes are available directly
3. **FactoryBot paths** - Engine factories are in `spec/factories/`, auto-loaded via engine initializer
4. **Running Rake Tasks** - Database migrations and other rake tasks can be run directly from the gem root (e.g., `bundle exec rails db:migrate`) as they are delegated to the dummy app via the engine's `Rakefile`.
