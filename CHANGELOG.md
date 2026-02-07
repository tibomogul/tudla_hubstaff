## [Unreleased]

## [0.1.0] - 2025-12-30

### Added

#### Engine Architecture
- Rails 8.1 mountable engine with `isolate_namespace` under `TudlaHubstaff`
- Solid trifecta integration (Solid Queue, Solid Cache, Solid Cable) with multi-database support
- Configurable host interface via `TudlaHubstaff.host_interface_class` for host app integration
- Integration with `tudla_contracts` gem — registers as a `time_sheet` provider via `TudlaContracts::Integrations::Registry`
- Configurable layout system allowing host apps to override the engine layout

#### Domain Models
- `User` — synced Hubstaff organization members with status enum (active/inactive/pending), email normalization, and Tudla user mapping
- `Project` — synced Hubstaff projects with type enum (project/work_order/work_break) and Tudla project mapping
- `Task` — synced Hubstaff tasks with Tudla task mapping
- `Activity` — synced Hubstaff daily activities with date and user tracking
- `Config` — polymorphic organization configuration storing Hubstaff organization ID and personal access token
- `OrganizationUpdate` — tracks last sync timestamp per organization for incremental activity fetching

#### Hubstaff API Integration
- `ApiConnection` — Faraday-based HTTP client with HTTPX adapter, OpenID Connect token discovery, and automatic OAuth2 refresh token rotation cached via Solid Cache
- `ApiClient` — typed API wrapper for Hubstaff v2 endpoints: members, projects, tasks, daily activities (by date and by updated timestamp), and individual task lookup with pagination support

#### Sync Services
- `SyncUsersService` — paginated sync of Hubstaff organization members with incremental update detection via `last_updated_at`
- `SyncProjectsService` — paginated sync of Hubstaff projects with incremental update detection
- `SyncTasksService` — paginated sync of Hubstaff tasks using shared `TaskSyncing` concern
- `SyncActivitiesService` — paginated sync of daily activities by date range using shared `ActivitySyncing` concern
- `FetchUpdatedActivitiesService` — paginated sync of recently updated activities for incremental polling
- `GetTaskService` — on-demand single task fetch and sync from the Hubstaff API

#### Background Jobs
- `FetchUpdatedActivitiesJob` — Solid Queue job that iterates all `OrganizationUpdate` records and incrementally syncs updated activities per organization

#### Entity Mapping UI
- Unmapped entity listing views with Pagy pagination for users, tasks, and projects
- Stimulus-powered mapping modal controllers for users, tasks, projects, and activity-to-task mapping with search/filter and pagination
- Turbo Stream responses for inline mapping updates without full page reloads
- JSON endpoints for searching available Tudla users, tasks, and projects from the host app via the host interface

#### ViewComponents
- `BaseComponent` — base class with engine route helpers for all components
- `UserRowComponent`, `TaskRowComponent`, `ProjectRowComponent`, `ActivityRowComponent` — table row components for entity listings
- `UserActivitiesListComponent` — paginated activity list per user with unmapped-only filtering (registered as a `dashboard_section` slot)
- `TaskActivitiesComponent` — activity list for a specific task (registered as a `task_show_tab` slot)
- **UI components** (`TudlaHubstaff::UI`):
  - `StatusBadgeComponent` — color-coded status badges
  - `PaginationComponent` — reusable pagination controls
  - `ModalComponent` — generic modal dialog
  - `MappingModalComponent` — specialized modal for entity mapping workflows
  - `MapButtonComponent` — trigger button for mapping modals
  - `TableComponent` — reusable table wrapper

#### Generators
- `tudla_hubstaff:views` — copies engine views to host app for customization, with optional scope filtering (users, tasks, projects, layouts)
- `tudla_hubstaff:components` — copies ViewComponents to host app, with scope filtering and `--templates_only` option for ERB-only ejection

#### Frontend
- Importmap Rails integration with engine-scoped JavaScript pins
- Tailwind CSS integration via `tailwindcss-rails`
- Stimulus controllers for user, task, project, and activity-task mapping modals with search, pagination, and async form submission
