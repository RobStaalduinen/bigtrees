# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BigTrees is a Rails 6 + Vue 2 SPA for managing an arborist/tree service business. It handles estimates, quoting, scheduling, invoicing, receipts, and team management. The app is deployed with Capistrano and uses MySQL in production.

- **Ruby**: 3.3.1 (see `.ruby-version`)
- **Rails**: ~6.0
- **Frontend**: Vue 2 + Vuex + Vue Router via Webpacker
- **Auth**: Custom session-token auth + Devise (password reset only)
- **Authorization**: Pundit (server-side) + role-based permissions via `Authorization` model (client-side)
- **Background jobs**: delayed_job
- **File storage**: AWS S3
- **Email**: Nylas API
- **Error tracking**: Sentry

## Commands

```bash
# Start Rails server
rails s

# Compile JS (development, with HMR)
./bin/webpack-dev-server

# Run all tests
bundle exec rspec

# Run a single spec file
bundle exec rspec spec/models/estimate_spec.rb

# Run a single example by line number
bundle exec rspec spec/models/estimate_spec.rb:42

# Rubocop lint
bundle exec rubocop

# DB migrations
bundle exec rails db:migrate

# Delayed job (background workers)
bundle exec rake jobs:work

# Deploy to production
bundle exec cap production deploy
```

## Architecture

### Rails Backend

The app is a standard Rails MVC app that serves both HTML views and JSON APIs consumed by the Vue SPA.

- **`app/controllers/`** — Standard Rails controllers; `ApplicationController` sets up Pundit authorization and `OrganizationContext` (multi-tenant org scoping via `X-ORGANIZATION-ID` header or session).
- **`app/models/`** — ActiveRecord models. `Estimate` is the central model with a rich state machine: it has both a `state` enum (`in_progress`, `on_hold`, `done`, `cancelled`) and a `status` enum (`needs_costs` → `needs_arborist` → `pending_quote` → `quote_sent` → `approved` → `work_scheduled` → `work_started` → `work_completed` → `final_invoice_sent` → `completed`). Status is automatically recalculated via `before_save :set_status`.
- **`app/policies/`** — Pundit policies for authorization.
- **`app/services/`** — Service objects (e.g., `estimates/duplicate.rb` for estimate duplication).
- **`app/modules/`** — Reusable Ruby modules: `excel/` (Excel file generation), `reports/` (reporting logic).
- **`lib/`** — Excel/PDF generation (uses `rubyXL`, `wicked_pdf`, `caxlsx`), scheduled tasks via `whenever`.

### Multi-tenancy

All data is scoped to an `Organization`. The current org is stored in `OrganizationContext` (a thread-local), set from the `X-ORGANIZATION-ID` request header. The Vue frontend stores the selected org ID in `localStorage` and sends it with every API request.

### Vue Frontend (SPA)

The admin panel (`/admin/*`) is a Vue 2 SPA mounted in `app/javascript/packs/application.js`. Routing is client-side via Vue Router.

- **`app/javascript/pages/`** — Top-level page components (estimates, customers, hours, receipts, etc.)
- **`app/javascript/components/`** — Reusable components organized by feature (estimate, trees, quote, invoice, costs, etc.) plus `ui/` (design system) and `form/` (form inputs)
- **`app/javascript/store/store.js`** — Vuex store with global state: authenticated user, organization, arborists list, estimates list
- **`app/javascript/models/`** — JS model classes: `Tree`, `TreeImage`, `Receipt`, `EmailDefinition`, `Authorization`
- **`app/javascript/mixins/axiosMixin.js`** — Global Vue mixin providing `axiosGet`, `axiosPost`, `axiosPut`, `axiosDelete`, `axiosDownload`. Sets CSRF token and org header automatically.
- **`app/javascript/mixins/permissionMixin.js`** — Global Vue mixin providing `hasPermission(page, permissionType)` and `featureEnabled(feature)`.

### Authorization Model

Arborists have a `role` field. `Roles.for_name(role)` returns role permissions used by the `Authorization` JS class. Route guards in Vue Router check `store.getters.hasPermission(page, type)` before navigating.

### Separate Entry Points

Beyond the main SPA, there are two additional Webpacker packs:
- `onboarding.js` — public-facing onboarding flow
- `property_management.js` — property management view

### Key Configuration

- `config/application.yml` (managed by Figaro) — environment variables/secrets
- `app/configuration_templates.yml` — org-level feature flags with defaults
- `config/schedule.rb` — cron jobs via whenever

## Testing

Tests use RSpec with FactoryBot. Specs live in `spec/models/`, `spec/controllers/`, and `spec/factories/`. `.rspec` auto-requires `spec_helper` and `rails_helper`.
