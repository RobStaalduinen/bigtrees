# Implementation Plan: Customers Directory — Card Body Enhancements (ENG-3)

## Resolved decisions

- **Blocker 2 (date format):** Option A accepted — add a new `shortDate` Vue filter in `admin.js`.
- **Blocker 3 (status format):** Use `formatted_status` from the `Estimate` model, surfaced via new methods on `Customer` and serialized in `CustomerListSerializer`.
- **Backend scope:** Backend changes are included in this plan.

## Resolved: both phone and email absent

The contact row is always rendered. When both phone and email are absent or invalid, display "No contact info" as a plain text fallback so staff can see at a glance that a record is incomplete.

---

## Execution order

Backend first, then frontend. Each task is independently verifiable.

---

## Task 1 — Update eager loading in `CustomersController#index`

**File:** `app/controllers/customers_controller.rb:9`

Change:
```ruby
@customers = policy_scope(Customer).order('customers.id DESC').includes(:estimates)
```
To:
```ruby
@customers = policy_scope(Customer).order('customers.id DESC').includes(:estimates, :address)
```

Adding `:address` prevents an N+1 query when the serializer reads address fields for each customer.

**Verify:** No change in response shape yet. Run the controller spec or hit the endpoint and confirm no additional SQL per customer in logs.

---

## Task 2 — Add `formatted_address`, `last_estimate_status`, and `last_activity_date` to `Customer` model

**File:** `app/models/customer.rb`

Add three methods after `estimate_count`:

```ruby
def formatted_address
  return nil unless address.present?
  [address.street, address.city, address.postal_code].compact.reject(&:empty?).join(', ').presence
end

def last_estimate_status
  estimates.max_by(&:id)&.formatted_status
end

def last_activity_date
  estimates.max_by(&:id)&.created_at&.to_date
end
```

Notes:
- `max_by(&:id)` operates on the in-memory preloaded collection (loaded by Task 1's `includes`). Do not use `estimates.order('id DESC').first` — that fires a new SQL query per customer.
- `formatted_status` is defined on `Estimate` at `app/models/estimate.rb:182` — it applies a special-case for `final_invoice_sent`, otherwise `status.gsub('_', ' ').capitalize`, producing display labels like "Quote sent".
- `to_date` strips the time component; the frontend only needs the date.
- `Address#full_address` (used elsewhere) is intentionally not changed — it omits postal_code and is depended on by mailers, PDFs, and quotes.

**Verify:** In the Rails console:
```ruby
c = Customer.includes(:estimates, :address).first
c.formatted_address   # => "123 Main St, Toronto, M4C 1A1" or nil
c.last_estimate_status  # => "Quote sent" or nil
c.last_activity_date    # => #<Date ...> or nil
```

---

## Task 3 — Update `CustomerListSerializer`

**File:** `app/serializers/customer_list_serializer.rb`

Replace the file contents with:

```ruby
# frozen_string_literal: true

class CustomerListSerializer < ApplicationSerializer
  attribute :name
  attribute :email
  attribute :phone
  attribute :estimate_count
  attribute :recent_estimate_id

  attribute :address do
    object.formatted_address
  end

  attribute :last_estimate_status
  attribute :last_activity_date
end
```

Changes from current:
- `has_one :address` removed — it serialized the full Address object (id, street, city, postal_code, full_address) into the response. Replaced by the `:address` attribute block which returns a plain formatted string or nil.
- `customer_address` and `site_address` conditional attributes removed — they were dead code in the list context (the index action never passes `include_addresses: true`; that option is only used by `CustomerSerializer` in the show action).
- `last_estimate_status` and `last_activity_date` added, delegating to the model methods from Task 2.

**Verify:** Hit `GET /customers.json` and confirm each customer object in the response has shape:
```json
{
  "id": 1,
  "name": "...",
  "email": "...",
  "phone": "...",
  "estimate_count": 3,
  "recent_estimate_id": 42,
  "address": "123 Main St, Toronto, M4C 1A1",
  "last_estimate_status": "Quote sent",
  "last_activity_date": "2025-03-12"
}
```
Customer with no address: `"address": null`. Customer with no estimates: `"last_estimate_status": null`, `"last_activity_date": null`.

---

## Task 4 — Add `shortDate` Vue filter

**File:** `app/javascript/packs/admin.js:163`

After the existing `localizeDate` filter, add:

```js
Vue.filter('shortDate', function(date) {
  return moment(date).format('D MMM YYYY');
})
```

This produces "12 Mar 2025" as the spec requires. The existing `localizeDate` filter (which produces "April 12th, 2025") is not used for this feature.

**Verify:** In the browser console after loading the admin app: `Vue.filter('shortDate')('2025-03-12')` returns `"12 Mar 2025"`.

---

## Task 5 — Rewrite card body in `singleCustomer.vue`

**File:** `app/javascript/components/customers/singleCustomer.vue`

Replace the entire `<template>` section with:

```html
<template>
  <div class='shadow-box-entry customer-list-entry'>
    <div class='customer-header'>
      <div class='customer-header-name'>{{ customer.name }}</div>
      <div class='customer-header-count'>{{ estimateCountText }}</div>
    </div>

    <div class='customer-list-body'>
      <div class='body-row' v-if='customer.address'>
        <b-icon icon='globe' class='contact-icon'></b-icon>
        {{ customer.address }}
      </div>

      <div class='body-row'>
        <template v-if='hasPhone || customer.email'>
          <template v-if='hasPhone'>
            <b-icon icon='telephone' class='contact-icon'></b-icon>
            <a :href="'tel:' + customer.phone">{{ customer.phone }}</a>
          </template>
          <template v-if='customer.email'>
            <b-icon icon='envelope' class='contact-icon' :class="{ 'icon-spaced': hasPhone }"></b-icon>
            <a :href="'mailto:' + customer.email">{{ customer.email }}</a>
          </template>
        </template>
        <span v-else class='no-contact'>No contact info</span>
      </div>

      <div class='body-row' v-if='customer.estimate_count > 0'>
        Last estimate: {{ customer.last_estimate_status }}
      </div>

      <div class='body-row' v-if='customer.estimate_count > 0'>
        Last active: {{ customer.last_activity_date | shortDate }}
      </div>
    </div>

    <div class='contact-actions'>
      <b-nav-item-dropdown id="customer-actions-dropdown" text="Actions" right>
        <b-dropdown-item :to='`/admin/estimates/${customer.recent_estimate_id}`'>
          Recent Estimate
        </b-dropdown-item>
        <b-dropdown-item :to='`/admin/estimates/new?customer_id=${customer.id}`'>
          New Estimate
        </b-dropdown-item>
      </b-nav-item-dropdown>
    </div>
  </div>
</template>
```

Replace the `<script>` section with:

```js
export default {
  props: {
    'customer': {
      type: Object,
      required: true
    }
  },
  computed: {
    estimateCountText() {
      const n = this.customer.estimate_count;
      if (n === 0) return 'No estimates';
      if (n === 1) return '1 estimate';
      return `${n} estimates`;
    },
    hasPhone() {
      const p = this.customer.phone;
      return p !== null && p !== '' && p !== '0';
    }
  }
}
```

Changes from current:
- `preferredString` method removed — the "(phone preferred)" labels are not in the new card body layout per spec. The underlying `preferred_contact` data is unchanged on the model.
- `customer-list-contact` div and its `contact-entry` children replaced by `customer-list-body` with `body-row` structure.
- Phone and email moved onto one line with conditional rendering via `hasPhone` computed.
- Address, last estimate status, and last activity date rows added.

**Verify the following cases against the running app:**
- All fields present: four rows visible in order (address, phone+email, last estimate, last active).
- `phone: null`: telephone icon and number absent; email still shows on the contact row.
- `phone: "0"`: same as null.
- `phone: ""`: same as null.
- `email: null`: envelope icon absent from contact row; phone still shows.
- `phone: null` and `email: null`: contact row shows "No contact info".
- `address: null`: address row absent entirely.
- `estimate_count: 0`: "Last estimate" and "Last active" rows absent.

---

## Task 6 — Update CSS in `singleCustomer.vue`

Replace the `<style scoped>` section with:

```css
<style scoped>
  .customer-list-entry {
    width: 100%;
    margin-bottom: 8px;
    display: flex;
    flex-direction: column;
    padding: 8px;
  }

  .customer-header {
    display: flex;
    justify-content: space-between;
    border-width: 0 0 1px 0;
    border-color: lightgray;
    border-style: solid;
    margin: -8px -8px 8px -8px;
  }

  .customer-header-name {
    font-weight: 600;
    padding: 4px 4px 4px 8px;
  }

  .customer-header-count {
    font-size: 12px;
    color: #666;
    background-color: #f0f0f0;
    border-radius: 12px;
    padding: 2px 10px;
    align-self: center;
    margin-right: 4px;
  }

  .customer-list-body {
    display: flex;
    flex-direction: column;
    font-size: 14px;
    padding-left: 4px;
  }

  .body-row {
    display: flex;
    align-items: center;
    margin-bottom: 4px;
  }

  .contact-icon {
    color: var(--main-color);
    margin-right: 4px;
  }

  .icon-spaced {
    margin-left: 12px;
  }

  .no-contact {
    color: #999;
    font-style: italic;
  }

  .contact-actions {
    display: flex;
    justify-content: flex-end;
    font-size: 14px;
    border-width: 1px 0 0 0;
    border-color: lightgray;
    border-style: solid;
    margin: 0 -8px -8px -8px;
  }

  #customer-actions-dropdown {
    list-style: none;
  }

  #customer-actions-dropdown >>> a {
    padding: 6px 12px;
  }
</style>
```

Removed: `.customer-list-contact`, `.contact-entry`, `.preferred` (no longer in template).
Added: `.customer-list-body`, `.body-row`, `.icon-spaced`.

**Verify:** Visual comparison with `estimates/single.vue` — icon colour, spacing, and font size should match.

---

## Out of scope (confirmed by spec)

- Card header or card actions.
- `Address#full_address` — intentionally not modified; postal_code omission there is by design for existing mailers/PDFs.
- `preferred_contact` display — removed from card body per new layout; data remains on the model.
