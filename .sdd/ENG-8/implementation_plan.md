# ENG-8 — Scheduling Emails — Implementation Plan

## Scope summary

Add a "Send Schedule Email" action available on estimates between status `approved` (40) and `work_started`/`work_paused` (i.e. inclusive of `approved`, `work_scheduled`, `work_started`, `work_paused`; excluded once `work_completed` 60+). The action lets a user pick one of several **scheduling** category email templates, edit subject/body inline, and send. The send is recorded as an `EmailRecord` (same mechanism as approval and quote mailouts). To support categorization we add a `category` string column to `email_templates` (default `"default"`) and seed two new templates (`48_hour_notice`, `crew_on_the_way`) with `category: "scheduling"` for every organization.

Read alongside:
- `email_content.md` (canonical body text for the two new templates — note placeholder normalization below).

## Decisions confirmed with the user
- Two new templates: `48_hour_notice` and `crew_on_the_way` (bodies in `email_content.md`).
- "Send Schedule Email" lives in the **existing Actions dropdown** (`actionsList.vue`), conditionally rendered.
- `category` column is a **plain string with DB default `"default"`**, not an enum.
- Switching templates in the form **refetches and resets** subject + body (no edit-preservation prompt).

## Open issues / things to confirm before coding (non-blocking but worth a glance)
1. **Placeholder normalization.** The bodies in `email_content.md` use `[Client Name]` and `-- INSERT SIGNATURE --`. The codebase's substitution logic (`app/javascript/content/organizationEstimateMailer.js:38-39`) only knows `[FIRST_NAME]` and `[SIGNATURE]`. I'll normalize the seeded bodies to use `[FIRST_NAME]` and `[SIGNATURE]` so substitution works automatically; the visible result will be the same content otherwise. If you want literal `[Client Name]` preserved, say so before Step 3.
2. **Subject placeholders.** `[ORGANIZATION_NAME]` substitution already works via `EmailTemplate#parsed_subject` (model). I'll use it in subjects unchanged.
3. **Existing `EmailTemplate::KEYS` constant** (`app/models/email_template.rb:16`) only lists `quote_mailout`. It is unused as a closed enumeration in current code; I'll leave it alone unless we want to start treating it as the source of truth for valid keys.
4. **Eligibility window.** Spec says "approved or above, but not yet in work_completed". I'm reading that as: status in `[approved, work_scheduled, work_started, work_paused]`. `work_paused` (57) sits between `work_started` and `work_completed` in the enum so it qualifies. Confirm if you'd rather exclude `work_paused`.

## Task list (ordered)

Each task is small enough to be merged & verified independently. Tasks within a phase can be parallelized; phases are sequential.

### Phase 1 — Data model: `category` on email templates

**T1.1 ✅ — Migration: add `category` column to `email_templates`.**
- New file: `db/migrate/<timestamp>_add_category_to_email_templates.rb`.
- `add_column :email_templates, :category, :string, default: 'default', null: false`
- `add_index :email_templates, :category`
- Backfill is implicit via DB default for existing rows.
- Update `db/schema.rb` (will regenerate on `db:migrate`).
- Update the schema comment block at the top of `app/models/email_template.rb` and `app/serializers/email_template_serializer.rb`.

**Acceptance:** `bundle exec rails db:migrate` succeeds; `EmailTemplate.column_names` includes `"category"`; existing rows have `category = "default"`.

**T1.2 ✅ — Expose `category` in serializer.**
- `app/serializers/email_template_serializer.rb`: add `attribute :category`.

**Acceptance:** `GET /email_templates` JSON includes `category` per template.

### Phase 2 — Backend: seeding new scheduling templates

**T2.1 ✅ — Update `EmailTemplateCreator` to seed scheduling templates.**
- File: `app/services/organization_creator/email_template_creator.rb`.
- Modify `seed_email_templates` to also call `create_48_hour_notice` and `create_crew_on_the_way`.
- Modify `create_email_template(key, subject, content)` → `create_email_template(key, subject, content, category: 'default')` and set `t.category = category` in the `find_or_create_by` block.
- Update the existing `create_*` methods unchanged (they default to `'default'`).
- Add `create_48_hour_notice` and `create_crew_on_the_way` using the bodies from `email_content.md`, **normalized** to use `[FIRST_NAME]` and `[SIGNATURE]` placeholders. Pass `category: 'scheduling'`.

**Acceptance:** Calling the service on a fresh org creates 8 templates: 6 with `category=default` and 2 with `category=scheduling` (keys `48_hour_notice`, `crew_on_the_way`).

**T2.2 ✅ — Update existing creator spec for the new templates.**
- File: `spec/services/organization_creator/email_template_creator_spec.rb`.
- Change `change(EmailTemplate, :count).by(6)` → `by(8)`.
- Change `contain_exactly(...)` list to include `'48_hour_notice'` and `'crew_on_the_way'`.
- Update the "is idempotent" check: `eq(6)` → `eq(8)`.
- Update the "inserts missing templates" expectation: `by(5)` → `by(7)`.
- Add one new example: scheduling templates are persisted with `category: 'scheduling'`; existing six with `category: 'default'`.

**Acceptance:** `bundle exec rspec spec/services/organization_creator/email_template_creator_spec.rb` is green.

**T2.3 ✅ — Backfill migration: seed the two new templates for existing orgs.**
- New file: `db/migrate/<timestamp+1>_seed_scheduling_email_templates.rb`.
- Model: reuse the existing pattern (see `db/migrate/20260524000000_seed_approval_mailout_email_template.rb`): iterate `Organization.find_each` and call `OrganizationCreator::EmailTemplateCreator.new(org).seed_email_templates` — `find_or_create_by` makes it idempotent.
- `down`: `EmailTemplate.where(key: ['48_hour_notice', 'crew_on_the_way']).destroy_all` (mirrors the existing pattern).

**Acceptance:** Running migration creates the two new templates for every org that doesn't already have them; rerunning is a no-op.

### Phase 3 — Backend: new "scheduling mailouts" endpoint

**T3.1 ✅ — Add `scheduling_mailouts` route.**
- File: `config/routes.rb`.
- Inside `resources :estimates do …`, alongside `resources :approval_mailouts, only: [:create]`, add `resources :scheduling_mailouts, only: [:create]`.

**Acceptance:** `bundle exec rails routes | grep scheduling_mailouts` shows `POST /estimates/:estimate_id/scheduling_mailouts`.

**T3.2 ✅ — Add `SchedulingMailoutsController`.**
- New file: `app/controllers/scheduling_mailouts_controller.rb`.
- Mirror `ApprovalMailoutsController` (`app/controllers/approval_mailouts_controller.rb:1-29`) but:
  - Accept `template_key` from params (similar to `QuoteMailoutsController` at `app/controllers/quote_mailouts_controller.rb:33`).
  - Validate the chosen key belongs to this org **and** has `category: 'scheduling'` — reject otherwise with a 422 (`render json: { error: 'invalid scheduling template' }, status: :unprocessable_entity`).
  - Otherwise call `QuoteMailer.new.quote_email(@estimate, params[:dest_email], params[:subject], params[:content], false)` (no PDF attached — same as approval mailouts).
  - Call `record_customer_email(estimate: @estimate, template_key: params[:template_key], nylas_response: response, recipient_email: params[:dest_email])`.

**Acceptance:** Controller exists; happy-path tests below pass.

**T3.3 ✅ — Controller spec.**
- New file: `spec/controllers/scheduling_mailouts_controller_spec.rb`.
- Model the structure after `spec/controllers/approval_mailouts_controller_spec.rb` (which is already written and known-passing).
- Cases to cover:
  - Happy path with `template_key: '48_hour_notice'` → 200, `QuoteMailer#quote_email` called with `include_quote: false`, one `EmailRecord` created with `template_key: '48_hour_notice'`.
  - Same for `crew_on_the_way`.
  - Rejecting an invalid key (e.g. `quote_mailout` — category is `default`, not `scheduling`): 422, no `EmailRecord` created, `QuoteMailer` not called.
  - Unauthenticated → redirect/unauthorized.
  - Cross-org estimate → 500 (matches existing approval spec — policy scope `.find` raises).

**Acceptance:** `bundle exec rspec spec/controllers/scheduling_mailouts_controller_spec.rb` is green.

### Phase 4 — Frontend: select-driven templated email form

**T4.1 ✅ — Make `templatedEmail.vue` react to a changing `template` prop.**
- File: `app/javascript/components/common/forms/templatedEmail.vue`.
- Currently the component fetches the template once on `mounted()` (`templatedEmail.vue:104-109`). Add a `watch` on the `template` prop that re-runs the same `axiosGet('/email_templates/<key>')` + `updateEmailDefinition` logic.
- The behavior must be idempotent: switching to the same key shouldn't trigger duplicate fetches; switching to a new key resets `emailSubject`, `emailBody`, and `baseContent`.
- Existing call sites (`approve.vue`, `sendInitial.vue`) pass a static `template` prop — behavior unchanged for them.

**Acceptance:** Manually swap `:template` prop binding in a sandbox or via the new component (T4.2) and confirm the body/subject reset on change. Existing approve & send-quote flows still work.

**T4.2 ✅ — New action component: `sendSchedule.vue`.**
- New file: `app/javascript/components/estimate/actions/sendSchedule.vue`.
- Modeled after `approve.vue` (`app/javascript/components/estimate/actions/approve.vue:1-69`).
- UI:
  - `app-right-sidebar` with title "Send Schedule Email", submit text "Send".
  - `app-select-field` bound to local `selectedTemplateKey`; options populated from a `GET /email_templates` call on `mounted`, filtered to `category === 'scheduling'`. Default to the first option.
  - `app-email-form` (`templatedEmail.vue`) with `:template="selectedTemplateKey"` (reactive — that's what T4.1 enables) and `:estimate="estimate"`.
- On submit:
  - `POST /estimates/${estimate.id}/scheduling_mailouts` with `{ dest_email, subject, content, template_key: selectedTemplateKey }`.
  - On success: emit `bv::toggle::collapse` to close, emit `ESTIMATE_UPDATED` on `EventBus` (matches `approve.vue:54-55`).

**Acceptance:** Unit-level (manual) — open the action, switch templates, confirm body/subject swap; submit calls the right endpoint with the right payload.

**T4.3 ✅ — Wire the new action into `listActionHandler.vue`.**
- File: `app/javascript/components/estimate/utils/listActionHandler.vue`.
- Import `sendSchedule.vue` as `SendSchedule`.
- Add an entry to the `ACTIONS` map (lines 21-50):
  ```js
  'send_schedule_email': {
    actionLabel: 'Send Schedule Email',
    inputComponent: 'estimate-send-schedule'
  }
  ```
- Register the component in the `components:` block: `'estimate-send-schedule': SendSchedule`.

**Acceptance:** Triggering `ESTIMATE_TRIGGER_ACTION` with name `'send_schedule_email'` opens the new sidebar.

**T4.4 ✅ — Add the menu entry + eligibility helper.**
- File: `app/javascript/components/estimate/utils/estimateHelper.js`. Add:
  ```js
  canSendSchedulingEmail() {
    return ['approved', 'work_scheduled', 'work_started', 'work_paused'].includes(this.estimate.status);
  }
  ```
- File: `app/javascript/components/estimates/actionsList.vue`. Add a new dropdown item near the existing "Send Followup":
  ```html
  <b-dropdown-item @click='triggerAction("send_schedule_email")' v-if='estimateHelper.canSendSchedulingEmail()'>
    Send Schedule Email
  </b-dropdown-item>
  ```

**Acceptance:** On an estimate in any of those four statuses, the dropdown shows "Send Schedule Email"; on `quote_sent`, `work_completed`, `final_invoice_sent`, etc., it is hidden.

### Phase 5 — End-to-end manual verification

**T5.1 ⏳ — Manual smoke test (engineer step — requires browser).**
1. Run pending migrations (`bundle exec rails db:migrate`).
2. As an existing org user, navigate to Email Templates page → verify the two new scheduling templates appear and can be edited (the existing list page treats all keys generically, so no UI change should be needed there — confirm).
3. Open an estimate in status `approved` (or `work_scheduled` / `work_started` / `work_paused`):
   - Actions dropdown shows "Send Schedule Email".
   - Click it; sidebar opens; switch between the two scheduling templates and confirm subject/body swap.
   - Send; verify an `EmailRecord` is created with the chosen `template_key`.
4. Open an estimate in status `quote_sent` or `work_completed` and confirm the option is hidden.
5. Open the existing **Approve** and **Send Quote** sidebars and verify they still load template content correctly (regression check for T4.1).

**Acceptance:** Each step behaves as described; no console errors; `EmailRecord` rows look right in the DB.

## Files touched (summary)

**Created**
- `db/migrate/<ts>_add_category_to_email_templates.rb`
- `db/migrate/<ts+1>_seed_scheduling_email_templates.rb`
- `app/controllers/scheduling_mailouts_controller.rb`
- `spec/controllers/scheduling_mailouts_controller_spec.rb`
- `app/javascript/components/estimate/actions/sendSchedule.vue`

**Modified**
- `app/services/organization_creator/email_template_creator.rb`
- `spec/services/organization_creator/email_template_creator_spec.rb`
- `app/models/email_template.rb` (schema comment only)
- `app/serializers/email_template_serializer.rb` (add `category` attribute + schema comment)
- `db/schema.rb` (regenerated by migrations)
- `config/routes.rb`
- `app/javascript/components/common/forms/templatedEmail.vue` (watch on `template` prop)
- `app/javascript/components/estimate/utils/listActionHandler.vue`
- `app/javascript/components/estimate/utils/estimateHelper.js`
- `app/javascript/components/estimates/actionsList.vue`

## Risks & notes

- **Reactive `template` prop change in `templatedEmail.vue`** is the only refactor of shared code in this plan. Two existing call sites pass a static prop, so behavior should be unchanged for them — but worth double-checking during T5.1.
- **Authorization.** Reusing `authorize Estimate, :update?` and `policy_scope(Estimate)` mirrors approval mailouts. If you want stricter policy gating (e.g. a dedicated permission), call it out and we'll add a Pundit policy.
- **No frontend "email history" view exists today.** The spec phrase "recorded similarly to approvals or quotes in the customer email history" is satisfied by writing to `EmailRecord` via `CustomerEmailRecordable` — same mechanism approval and quote mailouts already use. No new frontend surface is in scope unless you want one.
