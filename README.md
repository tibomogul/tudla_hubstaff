# TudlaHubstaff

`TudlaHubstaff` is a Rails 8.1 mountable engine that provides a seamless integration with the **Hubstaff API v2**. It is built with the "Solid trifecta" (Solid Queue, Solid Cache, and Solid Cable) and integrates into the `TudlaContracts` ecosystem.

## Features

- **Hubstaff API v2 Integration**: Fetch daily activities, members, and tasks.
- **Automated OAuth2**: Handles token refreshing and discovery automatically via `OpenIDConnect`.
- **Solid Stack Integration**: SQL-backed background jobs, caching, and pub/sub.
- **TudlaContracts Compatible**: Registers as a `time_sheet` provider.

## Installation

Add this gem to your application's Gemfile:

```ruby
gem "tudla_hubstaff"

# Since tudla_contracts is currently unpublished, you may also need:
gem "tudla_contracts", git: "https://github.com/tibomogul/tudla_contracts.git"
```

And then execute:
```bash
$ bundle install
```

### Database Setup

This engine uses the Solid trifecta. Ensure your host application is configured with the necessary databases (primary, queue, cache, cable) as described in the [Solid Rails documentation](https://github.com/rails/solid_queue).

## Configuration

The engine registers itself automatically with `TudlaContracts`. You typically interact with it via the `TudlaHubstaff::Provider`.

To initialize a connection, you need a Hubstaff Personal Access Token (used as the initial refresh token):

```ruby
config = { personal_access_token: "your_pat_here", organization_id: "your_org_id" }
provider = TudlaHubstaff::Provider.new(config)
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
