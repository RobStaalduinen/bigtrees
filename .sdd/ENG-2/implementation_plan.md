# ENG-2 Implementation Plan: Customers Page Design Alignment

## Pre-implementation decisions

**Decision 1 — `estimate_count` API dependency**
The card header estimate count (task 3) reads `customer.estimate_count` from the API response. This field is specified in a separate backend spec. Confirm the backend changes are deployed (or deployed to the dev environment) before implementing task 3. If not available, tasks 1, 2, and 4 can proceed independently — task 3 must wait.

Answer: Serailized customers should now have an estimate_count

**Decision 2 — Warm background tint color [spec gap]**
The spec says "matching the estimates page" but no background color is applied to the estimates page at any level in the current CSS (no body tint, no page-level scoped style, no CSS variable). Before implementing task 5, inspect the running estimates page in the browser and confirm: (a) whether a warm tint actually renders there today, and (b) what specific color value to use. If no tint exists on estimates either, the spec author needs to supply a hex/rgb value.

Answer: This was a mistake in specification, it can be ignored.

**Decision 3 — Card header shading color [minor design decision]**
The estimate card's `.estimate-header` (`single.vue:97`) has no background color — only a `border-bottom: 1px solid lightgray`. The spec calls for a "visually distinct shaded" header row on customer cards. The developer needs to pick a shade (candidates: `#f9f9f9`, `#eeeeee`) by looking at the running estimates page or confirming with the author.

Answer: No shading is necessary in the header row. We just need to make sure hte header row is distinct in the same way that estimates are.

**Decision 4 — Dropdown component (spec Q1 answered)**
`estimates/actionsList.vue` is not reusable — it's tightly coupled to the EventBus, EstimateHelper, and estimate-specific actions. The customer card dropdown should use `<b-nav-item-dropdown>` inline within `singleCustomer.vue`, the same pattern as the estimates card. No new shared component needed.

---

## Tasks

### Task 1 — Swap paginator in `customerList.vue`

Replace `<app-pagination>` (lines 6–10) with `<app-arrow-pagination>`. Both components are globally registered in `admin.js`. Add `perPage: 30` to `data()` to preserve the existing page size.

```
// Remove:
<app-pagination v-model='currentPage' :totalRows='totalCustomers'>

// Add:
<app-arrow-pagination :totalEntries='totalCustomers' :perPage='perPage' v-model='currentPage'>

// data():
perPage: 30
```

The existing `currentPage` watcher already calls `retrieveCustomers()`, so no other wiring is needed.

Verify: paginating through customers shows "X – Y of Z" format with chevrons; prev chevron disabled on page 1, next disabled on last page.

---

### Task 2 — Narrow search field + add Reset button in `customerList.vue`

Restructure `#search-container` to flex-row with a 60%-wide search field and a Reset button to its right, matching the estimates list layout (`list.vue:6–10`).

- Change `#search-container` to `display: flex; justify-content: space-between`
- Wrap `<app-search-field>` in a `#search-field-container` div styled to `width: 60%`
- Add `<app-button text='Reset' :click='resetSearch'>` next to it
- Add `resetSearch()` method: sets `searchTerm = null`, `currentPage = 1`
- Update the `searchTerm` watcher to also reset `currentPage = 1` (currently it does not — this prevents stale pagination on filtered results)

Verify: search field no longer stretches full width; Reset clears input and reloads unfiltered list starting at page 1.

---

### Task 3 — Add shaded header row with estimate count to `singleCustomer.vue`

*Blocked on: Decision 3 (shading color), and `estimate_count` in API response (Decision 1).*

Restructure the card to add a header row above the contact section:

- Add a `customer-header` div as the first child of `.shadow-box-entry`
  - Left side: customer name (moved from the `.customer-list-contact` area)
  - Right side: estimate count text
- Remove the `.customer-name` span from `.customer-list-contact`
- Add an `estimateCountText` computed property:
  ```js
  estimateCountText() {
    const n = this.customer.estimate_count;
    if (n === 0) return 'No estimates';
    if (n === 1) return '1 estimate';
    return `${n} estimates`;
  }
  ```
- Style `.customer-header`: `display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid lightgray; background-color: <confirmed shade>;`

Verify: header row is visually distinct; name is left-aligned; count is right-aligned; singular/plural/zero all render correctly.

---

### Task 4 — Replace action buttons with Actions dropdown in `singleCustomer.vue`

Remove the two `<b-button>` elements from `.contact-actions` (lines 15–16 of `singleCustomer.vue`). Replace with a `<b-nav-item-dropdown>` inline, preserving the existing route targets.

```html
<b-nav-item-dropdown id="customer-actions-dropdown" text="Actions" right>
  <b-dropdown-item :to='`/admin/estimates/${customer.recent_estimate_id}`'>
    Recent Estimate
  </b-dropdown-item>
  <b-dropdown-item :to='`/admin/estimates/new?customer_id=${customer.id}`'>
    New Estimate
  </b-dropdown-item>
</b-nav-item-dropdown>
```

Add scoped style override matching `actionsList.vue:98`:
```css
#customer-actions-dropdown >>> a {
  padding: 6px 12px;
}
```

Remove the `#new-estimate-button` scoped style that's now unused.

Verify: "Actions ▼" dropdown appears in card footer; both items navigate to the correct routes; no "Details" link present.


## Execution order

Tasks 1, 2, and 4 are independent of each other and of the backend. Task 3 requires the backend `estimate_count` field and the shading color decision.

Suggested order given the decisions: **1 → 2 → 4 → 3
