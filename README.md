# TudlaHubstaff

`TudlaHubstaff` is a Rails 8.1 mountable engine that provides a seamless integration with the **Hubstaff API v2**. It is built with the "Solid trifecta" (Solid Queue, Solid Cache, and Solid Cable) and integrates into the `TudlaContracts` ecosystem.

## Features

- **Hubstaff API v2 Integration**: Fetch daily activities, members, and tasks.
- **Automated OAuth2**: Handles token refreshing and discovery automatically via `OpenIDConnect`.
- **Solid Stack Integration**: SQL-backed background jobs, caching, and pub/sub.
- **TudlaContracts Compatible**: Registers as a `time_sheet` provider.
- **ViewComponent Architecture**: Modular, testable UI components with slot-based composition.
- **Unmapped Entity Management**: Built-in views for mapping Users, Tasks, and Projects to Tudla entities.
- **Customizable Views**: Generator-based ejection pattern for host app customization.

## Installation

Add the gem to your application's Gemfile:

```ruby
gem "tudla_contracts"
gem "tudla_hubstaff"
```

And then execute:
```bash
$ bundle install
```

### Mounting the Engine

Mount the engine in your application's `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount TudlaHubstaff::Engine => "/tudla_hubstaff"
end
```

### Installing Migrations

Copy the engine's migrations to your application:

```bash
$ bin/rails tudla_hubstaff:install:migrations
```

Then run the migrations:

```bash
$ bin/rails db:migrate
```

### Generating the engine's Tailwind import file

We are using`tailwindcss-rails` experiment support https://github.com/rails/tailwindcss-rails?tab=readme-ov-file#rails-engines-support-experimental

Run the following command to generate the engine's Tailwind import file `app/assets/builds/tailwind/tudla_hubstaff.css`:
```bash
$ bin/rails tailwindcss:engines
```

Edit your `app/assets/tailwind/application.css` to import the engine's Tailwind import file:
```css
@import "../builds/tailwind/tudla_hubstaff";
```

### Importing the engine's JavaScript

Edit your `app/javascript/application.js` to import the engine's JavaScript:
```javascript
import "tudla_hubstaff/controllers/index"
```

### Database Setup

This engine uses the Solid trifecta. Ensure your host application is configured with the necessary databases (primary, queue, cache, cable) as described in the [Solid Rails documentation](https://github.com/rails/solid_queue).

## Configuration

The engine registers itself automatically with `TudlaContracts`. You typically interact with it via the `TudlaHubstaff::Provider`.

To initialize a connection, you need a Hubstaff Personal Access Token (used as the initial refresh token):

```ruby
config = TudlaHubstaff::Config.new
config.tudla_organization = Organization.first
config.personal_access_token = ENV["HUBSTAFF_PAT"]
config.organization_id = ENV["HUBSTAFF_VALUEPRO_ID"].to_i
config.save

# provider = TudlaHubstaff::Provider.new(config)
```

### Host Interface Configuration

The engine requires a host interface class to provide available Tudla entities for mapping. Configure this in an initializer:

```ruby
# config/initializers/tudla_hubstaff.rb
TudlaHubstaff.host_interface_class = "::HubstaffHostInterface"
```

Your class must inherit from `TudlaContracts::Integrations::HostInterface` and implement:

```ruby
class YourApp::HubstaffHostInterface < TudlaContracts::Integrations::HostInterface
  def available_users_for_user(current_user)
    # Return array of objects with :id, :name, :email
  end

  def available_tasks_for_user(current_user)
    # Return array of objects with :id, :name, :project_name
  end

  def available_projects_for_user(current_user)
    # Return array of objects with :id, :name
  end
end
```

### Layout Configuration

By default, the engine uses its own layout. To use your application's layout:

```ruby
# config/initializers/tudla_hubstaff.rb
TudlaHubstaff::Engine.config.tudla_hubstaff.layout = "application"
```

## Usage

### Fetching Activities

```ruby
activities = provider.daily_activities
```

### Advanced API Access

For more granular control, use the `ApiClient`:

```ruby
connection = TudlaHubstaff::ApiConnection.new("your_pat")
client = TudlaHubstaff::ApiClient.new("your_org_id", connection)

# Fetch members
members = client.members

# Fetch tasks
tasks = client.tasks(status: "active")
```

## Scheduling Background Jobs

The engine includes a `FetchUpdatedActivitiesJob` that syncs activity updates from Hubstaff. **The host application must schedule this job to run periodically.**

### Using Solid Queue (Recommended)

Add a recurring job in your host application's `config/recurring.yml`:

```yaml
production:
  fetch_hubstaff_activities:
    class: TudlaHubstaff::FetchUpdatedActivitiesJob
    schedule: every 15 minutes
```

### Using Cron or Other Schedulers

If you prefer cron or another scheduler, enqueue the job periodically:

```ruby
TudlaHubstaff::FetchUpdatedActivitiesJob.perform_later
```

**Note:** Before the job can process an organization, you must create an `OrganizationUpdate` record with a `last_updated_at` timestamp. Records with `nil` timestamps are skipped.

## Architecture

- **`TudlaHubstaff::Provider`**: The main entry point for the `TudlaContracts` interface.
- **`TudlaHubstaff::ApiClient`**: Handles Hubstaff v2 API endpoints.
- **`TudlaHubstaff::ApiConnection`**: Manages Faraday connections and OAuth2 token lifecycle.
- **Caching**: Access tokens and refresh tokens are stored in `Rails.cache` (backed by `SolidCache`).

### ViewComponent Architecture

The engine uses [ViewComponent](https://viewcomponent.org/) for modular, testable UI components:

- **`TudlaHubstaff::BaseComponent`**: Base class with engine route helpers
- **`TudlaHubstaff::UI::ModalComponent`**: Reusable modal with slots (header, body, footer)
- **`TudlaHubstaff::UI::TableComponent`**: Table with header and rows slots
- **`TudlaHubstaff::UI::PaginationComponent`**: Pagination with configurable path helper
- **`TudlaHubstaff::UI::StatusBadgeComponent`**: Status badges with color coding
- **`TudlaHubstaff::UI::MappingModalComponent`**: Specialized modal for entity mapping
- **`TudlaHubstaff::UI::MapButtonComponent`**: Button to trigger mapping modal

## Customizing Views

The engine provides generators to copy views and components to your application for customization.

### Copy All Views

```bash
rails g tudla_hubstaff:views
```

### Copy Scoped Views

```bash
# Copy only user views
rails g tudla_hubstaff:views users

# Copy only task views
rails g tudla_hubstaff:views tasks

# Copy only project views
rails g tudla_hubstaff:views projects
```

### Copy Components

```bash
# Copy all components (Ruby classes and templates)
rails g tudla_hubstaff:components

# Copy only component templates (recommended for customization)
rails g tudla_hubstaff:components --templates_only

# Copy specific component scope
rails g tudla_hubstaff:components ui
```

**Note:** When copying only templates, the engine retains control over the component logic while you customize the presentation.

## Testing

The engine uses RSpec for testing. A dummy Rails application is located in `spec/dummy`.

### Database Setup for Tests

**Important:** Rails 8 with the Solid trifecta uses multiple databases (primary, queue, cache, cable). When resetting the test database, you must load each schema separately.

```bash
# One-time setup or when you need a complete refresh
RAILS_ENV=test bundle exec rails db:reset

# Load Solid gem schemas (required after db:reset)
RAILS_ENV=test bundle exec rails app:db:schema:load:cache
RAILS_ENV=test bundle exec rails app:db:schema:load:queue
RAILS_ENV=test bundle exec rails app:db:schema:load:cable

# Run the specs
bundle exec rspec
```

**Quick workflow for ongoing development:**

```bash
# When adding new migrations
RAILS_ENV=test bundle exec rails db:migrate

# Run tests
bundle exec rspec
```

**Note:** `db:reset` only loads the primary database schema. The Solid gem databases (cache, queue, cable) have separate schema files that must be loaded explicitly.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
