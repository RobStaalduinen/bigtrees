# ENG-7 — Approval-email template + idempotent seeder

## Goal

When an arborist marks an estimate as **approved** in the admin SPA, optionally send the customer a templated "your job is scheduled" email. The email is on by default but can be unchecked. The template itself must be editable per-organization through the existing email-templates admin UI, and the `OrganizationCreator::EmailTemplateCreator` seeder must (a) include this new template and (b) be re-runnable on existing organizations without duplicating rows.

## Decisions (locked from clarification)

| Topic | Decision |
| --- | --- |
| Default email content | `.sdd/ENG-7/email_content.md` (the scheduling email body). Subject: `Your [ORGANIZATION_NAME] Job`. |
| Template key | `approval_mailout` (mirrors `quote_mailout` / `invoice_mailout` naming). |
| UI placement | Inline checkbox in `app/javascript/components/estimate/actions/approve.vue` (default checked). |
| Send tracking | **No** new column on `estimates`. Rely on `EmailRecord` with `template_key: 'approval_mailout'` (matches existing audit pattern). |
| Seeder idempotency | `find_or_create_by(key:)` per template. Safe to re-run on any org; only inserts missing rows. |
| Endpoint | `POST /estimates/:estimate_id/approval_mailouts` (mirrors `quote_mailouts` / `invoice_mailouts`). |

## Reference: how the existing flow works (so we match the pattern)

- **Templated email pipeline** — Vue fetches raw template via `GET /email_templates/:key` (returns `subject`, `parsed_subject`, `content`). `templatedEmail.vue` renders it through `OrganizationEstimateMailer` (replaces `[FIRST_NAME]`, `[SIGNATURE]`, etc. client-side). The user can edit subject/body inline. On send, the **rendered** subject+content are POSTed to a mailout controller, which calls `QuoteMailer#quote_email` (Nylas) and writes an `EmailRecord` via the `CustomerEmailRecordable` concern. See `app/controllers/quote_mailouts_controller.rb` and `app/javascript/components/quote/actions/sendInitial.vue`.
- **Approval today** — `approve.vue` simply `PUT /estimates/:id { estimate: { approved: true } }`. `Estimate#set_status` (`app/models/estimate.rb:260-308`) then derives `status = :approved` from `quote_sent_date && approved && !work_start_date`.

The new flow keeps the approval `PUT` exactly as it is (so `status` derivation is untouched) and adds a **separate** `POST /approval_mailouts` call when the checkbox is checked, fired after the approval PUT resolves successfully. This mirrors how `quote_mailouts` is a sibling of the underlying estimate update rather than entangled with it.

---

## Implementation steps

### 1. Default content asset (`app/javascript/content/emailContent.js`)

The seeder content lives in Ruby (the seeder file). For the SPA preview we don't need a separate JS constant — `templatedEmail.vue` fetches the live template via `GET /email_templates/approval_mailout`, so the only place the default body is hardcoded is the seeder. Skip step 1 unless we need a "no schedule"-style content slot; we don't.

### 2. Seeder — `app/services/organization_creator/email_template_creator.rb`

Two changes:

**2a. Make every `create_*` idempotent.** Replace the single `create_email_template` helper with one that finds-or-creates by `key`, scoped to the organization:

```ruby
def create_email_template(key, subject, content)
  @organization.email_templates.find_or_create_by(key: key) do |t|
    t.subject = subject
    t.content = content
  end
end
```

`find_or_create_by(key:) do |t| ...` only runs the block (and saves the subject/content) on insert, so re-running the seeder on an org that already has `quote_mailout` will not overwrite an arborist's edits — it just leaves the existing row alone. That is the desired behaviour.

**2b. Add `create_approval_mailout` and wire it into `seed_email_templates`:**

```ruby
def seed_email_templates
  create_quote_mailout
  create_invoice_mailout
  create_receipt_mailout
  create_no_response
  create_image_request
  create_approval_mailout
end

def create_approval_mailout
  content = "Hi [FIRST_NAME],\n\n" \
            "We're pleased to let you know that your tree service is scheduled and our plan is to complete the work within 10 business days, weather permitting. If the job requires a permit, rest assured we are working on it and you will be made aware of the progress.\n\n" \
            "Our team will monitor weather conditions throughout the week. We'll be in touch with an update 1-2 days in advance as the schedule becomes more clear. Wind, rain, sickness and equipment delays factor in to every day — please be patient with us as we navigate our schedule as efficiently as possible.\n\n" \
            "No action is required on your part at this time.\n\n" \
            "Thank you, and we look forward to working with you!\n\n" \
            "Best regards,\n[SIGNATURE]\n"
  create_email_template('approval_mailout', 'Your [ORGANIZATION_NAME] Job', content)
end
```

Notes on the body:
- Prepend `Hi [FIRST_NAME],\n\n` so the existing `OrganizationEstimateMailer#defaultContent` → `replaceContentSlots` substitution does something useful (consistent with every other template).
- Replace the `--INSERT SIGNATURE--` placeholder from the source file with `[SIGNATURE]` — that is the placeholder `replaceContentSlots` knows how to substitute (`organizationEstimateMailer.js:39`).
- Smart quotes from the source file (`We're`, `We'll`) are normalised to ASCII apostrophes to avoid mojibake risk on the wire; the body is otherwise identical.

**2c. (Out of scope but worth flagging)** No rake task is needed — the user picked "find_or_create_by on key" only. To backfill the new template across existing orgs in production, the existing seeder can simply be re-invoked from a console one-liner: `Organization.find_each { |o| OrganizationCreator::EmailTemplateCreator.new(o).seed_email_templates }`. Call this out in the PR description; do not commit a rake task.

### 3. Backend — `ApprovalMailoutsController`

New file: `app/controllers/approval_mailouts_controller.rb`. Model it on `quote_mailouts_controller.rb` but trimmed since there are no estimate columns to update:

```ruby
class ApprovalMailoutsController < ApplicationController
  include CustomerEmailRecordable

  before_action :signed_in_user

  def create
    authorize Estimate, :update?
    @estimate = policy_scope(Estimate).find(params[:estimate_id])

    response = QuoteMailer.new.quote_email(
      @estimate,
      params[:dest_email],
      params[:subject],
      params[:content],
      false # include_quote — no PDF attachment for the approval confirmation
    )

    record_customer_email(
      estimate: @estimate,
      template_key: 'approval_mailout',
      nylas_response: response,
      recipient_email: params[:dest_email]
    )

    render json: @estimate
  end
end
```

Decisions inside this controller:
- **No `skip` param** — if the user unchecks the box, the SPA simply doesn't POST. Keeps the controller's contract single-purpose.
- **`include_quote: false`** — `QuoteMailer#quote_email`'s fifth arg controls the PDF attachment (see `app/mailers/quote_mailer.rb`); the approval email is text-only, so pass `false`. Verify the signature when implementing — if `QuoteMailer` doesn't accept a 5th arg, add the parameter rather than attaching the quote PDF to a confirmation email.
- **Hard-code `template_key: 'approval_mailout'`** rather than trusting `params[:template_key]` — there's only one template this endpoint sends, and hard-coding prevents the audit log being lied to.

### 4. Routes — `config/routes.rb`

Add inside the existing `resources :estimates do … end` block, next to `quote_mailouts`:

```ruby
resources :approval_mailouts, only: [ :create ]
```

### 5. Policy

`EmailTemplatePolicy` already covers the new key (it's just a row in the existing table — `EmailTemplatesController#show` does `find_by(key: params[:id])`). No policy changes needed. Authorization on the mailout itself piggybacks on `Estimate, :update?`, same as `quote_mailouts` / `invoice_mailouts`.

### 6. Vue — `app/javascript/components/estimate/actions/approve.vue`

Add a single checkbox to the existing form, default `true`. When `approveEstimate` runs:

1. PUT `/estimates/:id { estimate: { approved: true } }` as today.
2. **If** `sendEmail` is checked, on success render the template through `OrganizationEstimateMailer` and POST it to `/estimates/:id/approval_mailouts`.
3. Emit `ESTIMATE_UPDATED` with the response from the approval PUT (the mailout response is the estimate too, but the order keeps the UI consistent if the email call slow-loads).

Two implementation options for the email rendering:

- **Option A (simpler, recommended):** Don't show a preview/edit UI inside the Approve sidebar. Fetch the template, run it through `OrganizationEstimateMailer.defaultContent(...)`, and submit. The arborist edits the template via the email-templates admin page if they want to change the wording, and toggles off the checkbox if they don't want to send for this estimate. This keeps the sidebar tight (matches the chosen UX preview).
- **Option B (richer, do not implement unless asked):** Embed `templatedEmail.vue` inside the Approve sidebar (like `sendInitial.vue` does), letting the arborist tweak subject/body per-send.

Picking **A**. The sidebar mockup the user approved has just one checkbox; no preview.

Sketch:

```vue
<template>
  <app-right-sidebar-form
    :id='id'
    title='Approve'
    submitText='Approve'
    :onSubmit='approveEstimate'
    :submitting='submitting'
  >
    <template v-slot:content>
      <div>Customer has approved work?</div>
      <b-form-checkbox v-model='sendEmail' class='send-email-toggle'>
        Send approval email
      </b-form-checkbox>
    </template>
  </app-right-sidebar-form>
</template>

<script>
import EventBus from '@/store/eventBus'
import OrganizationEstimateMailer from '@/content/organizationEstimateMailer'

export default {
  props: { id: { required: true }, estimate: { required: true } },
  data() {
    return { submitting: false, sendEmail: true }
  },
  methods: {
    async approveEstimate() {
      this.submitting = true
      try {
        const approveResp = await this.axiosPut(`/estimates/${this.estimate.id}`, {
          estimate: { approved: true }
        })

        if (this.sendEmail) {
          await this.sendApprovalEmail()
        }

        this.$root.$emit('bv::toggle::collapse', this.id)
        EventBus.$emit('ESTIMATE_UPDATED', approveResp.data)
      } finally {
        this.submitting = false
      }
    },
    async sendApprovalEmail() {
      const tplResp = await this.axiosGet('/email_templates/approval_mailout')
      const tpl = tplResp.data.email_template
      const mailer = new OrganizationEstimateMailer(this.$store.state.organization, this.estimate)

      await this.axiosPost(`/estimates/${this.estimate.id}/approval_mailouts`, {
        dest_email: this.estimate.customer_detail.email,
        subject: tpl.parsed_subject,
        content: mailer.defaultContent(tpl.content)
      })
    }
  }
}
</script>
```

Failure-handling note: if the approval PUT succeeds but the email POST fails (Nylas down, customer has no email on file, etc.), the estimate is still approved — that is the correct outcome (approval is the source of truth; the email is a notification). Surface the email failure via the existing axios error toast; do **not** roll back the approval.

### 7. Tests

#### 7a. Seeder spec — **new** `spec/services/organization_creator/email_template_creator_spec.rb`

The seeder has no existing spec. Cover:

- Calling `seed_email_templates` on a fresh org creates exactly **6** templates (the five existing + `approval_mailout`) with the expected keys.
- `approval_mailout` row has subject `'Your <Org Name> Job'` after the `[ORGANIZATION_NAME]` replacement happens at read-time (note: the row stores `'Your [ORGANIZATION_NAME] Job'` literally; `parsed_subject` does the replacement). Assert against the stored value.
- **Idempotency:** calling `seed_email_templates` twice on the same org results in `count == 6`, not 12.
- **Idempotency does not clobber edits:** pre-create `approval_mailout` with a custom subject/content, run the seeder, assert the custom values are preserved (this is the contract that protects arborist edits during a backfill).
- **Partial backfill:** pre-create only `quote_mailout`, run the seeder, assert the other five keys are inserted and `quote_mailout` is unchanged.

#### 7b. Approval mailout controller spec — **new** `spec/controllers/approval_mailouts_controller_spec.rb`

Mirror the structure of the existing `estimates_controller_spec.rb` (FactoryBot + signed-in arborist). Stub `QuoteMailer#quote_email` so we don't hit Nylas. Cover:

- Authenticated arborist + valid estimate → 200, calls `QuoteMailer#quote_email` once with the params from the request, creates one `EmailRecord` with `template_key: 'approval_mailout'`.
- Unauthenticated → redirected/unauthorized (whatever the existing controller specs assert for `signed_in_user`).
- Estimate scoped to a different org → 404 (`policy_scope(Estimate).find` raises `ActiveRecord::RecordNotFound`).
- `EmailRecord` row contains the right `arborist`, `organization`, `recipient_email`, and a `sent_at` ≈ `Time.current`.

#### 7c. Existing estimate-status invariance — extend `spec/models/estimate_spec.rb`

The existing approved-status test already passes. No code change to the model. Add a one-liner sanity test only if reviewers want explicit coverage that "an estimate without an email record can still reach `status: approved`" — likely overkill given the model change is zero. **Skip** unless review asks.

#### 7d. Frontend — **out of scope for spec coverage**

There is no JS test setup in the repo (no `spec/javascript/`, no Jest config). Don't introduce one for this ticket. The Vue change is small enough to verify by running the dev server and clicking Approve with the box checked vs unchecked; call this out in the PR test plan.

### 8. Manual QA checklist (for the PR body)

- [ ] On an org with no approval template (i.e. existing prod orgs), run `OrganizationCreator::EmailTemplateCreator.new(org).seed_email_templates` in console → verify only `approval_mailout` is inserted.
- [ ] Edit the approval template via the admin UI → save → verify the next approval email uses the edited copy.
- [ ] Approve an estimate with the checkbox **checked** → arborist sees toast confirmation; customer inbox receives the rendered email; `EmailRecord` row exists.
- [ ] Approve an estimate with the checkbox **unchecked** → estimate transitions to `status: approved`; no `EmailRecord` row is created; no Nylas call made.
- [ ] Approve an estimate with checkbox checked but customer has no email on file → approval still succeeds, email POST surfaces an error, estimate status is `approved`.

---

## Files touched

| Change | File |
| --- | --- |
| Modify (idempotent helper + new template) | `app/services/organization_creator/email_template_creator.rb` |
| New controller | `app/controllers/approval_mailouts_controller.rb` |
| Modify (route) | `config/routes.rb` |
| Modify (checkbox + post-approve email call) | `app/javascript/components/estimate/actions/approve.vue` |
| New spec | `spec/services/organization_creator/email_template_creator_spec.rb` |
| New spec | `spec/controllers/approval_mailouts_controller_spec.rb` |

No schema migration. No new Vuex state. No changes to `Estimate#set_status`.

## Open questions / risks

1. **`QuoteMailer#quote_email` signature for `include_quote`** — I haven't read the mailer; the report mentions a 5-arg form but the existing call sites pass 4. Confirm during implementation; if there's no `include_quote` flag, either add one or use a different mailer method so the approval email doesn't attach a PDF.
2. **Customer email missing** — the SPA's Approve sidebar doesn't currently surface the customer email field. If `estimate.customer_detail.email` is blank, the checkbox should arguably be disabled with a tooltip ("No customer email on file"). Out of scope for this ticket unless QA flags it.
3. **Sending without quote-sent first** — `Estimate#set_status` only resolves to `approved` if `quote_sent_date` is present. If an arborist hits Approve before sending the quote (theoretically possible), the approval boolean flips but `status` stays elsewhere. Email still sends. This is consistent with the model's current contract; no fix here.
