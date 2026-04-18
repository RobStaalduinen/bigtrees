# Spec: Customers Directory — Frontend Design Alignment

**Jira Ticket:** [RST-XX](https://finlink.atlassian.net/browse/RST-XX)
**Date:** 2026-04-11
**Author:** Rob

---

## Overview

The customers directory page (`/admin/customers`) currently has a noticeably different visual design from the estimates page (`/admin/estimates`), which is the established design reference for admin list pages. This spec covers the structural and visual changes needed to bring the customers page into alignment — search bar layout, pagination, page background, card header structure, and card actions.

---

## Goals

- The customers directory page is visually consistent with the estimates page in layout and structure.
- Staff can navigate, search, and act on customer records using interaction patterns consistent with the rest of the admin area.

---

## Non-Goals / Out of Scope

- Adding a "New Customer" button or customer creation flow — customers are created organically through estimate/job creation.
- Changes to the customer card body content (covered in a separate spec).
- Backend changes (covered in a separate spec).
- A customer detail page — this does not exist yet and is deferred to a future spec. No "Details" link should be added.
- Filters — there is nothing to filter on at this stage. No Filters button should be added.

---

## Functional Requirements

1. **Search bar layout:** The search input should be narrowed (not full-width) to match the estimates page. A "Reset" button must be placed to its right.

2. **Reset button behaviour:** Clicking Reset clears the current search term and reloads the full unfiltered customer list.

3. **Pagination:** The existing numbered paginator (1, 2, 3 … 14) must be replaced with a compact results count in the format "X – Y of Z" and prev/next chevron arrows only. The prev arrow must be disabled on the first page; the next arrow must be disabled on the last page.

4. **Page background:** A warm background tint (matching the estimates page) must be applied to the full customers page.

5. **Card header row:** Each customer card must have a visually distinct shaded header row. The customer's name appears on the left. The customer's total estimate count appears on the right (e.g. "5 estimates" or "1 estimate" — singular/plural as appropriate). If the count is zero, it should display "No estimates".

6. **Card actions:** The existing "Recent Estimate" and "New Estimate" buttons in the card footer must be replaced with an "Actions ▼" dropdown button, matching the visual style of its equivalent on the estimates page. There is no "Details" link in this iteration.

7. **Actions dropdown contents:** The dropdown must contain "Recent Estimate" and "New Estimate" as items, preserving the existing functionality of the removed buttons.

---

## Acceptance Criteria

- [ ] Search input is no longer full-width; Reset button appears to its right.
- [ ] Clicking Reset clears the search field and reloads the unfiltered list.
- [ ] Numbered pagination is removed and replaced with "X – Y of Z" + prev/next chevrons.
- [ ] Prev chevron is disabled/greyed on page 1; next chevron is disabled/greyed on the last page.
- [ ] Page background matches the warm tint used on the estimates page.
- [ ] Each card has a shaded header row with the customer name (left) and estimate count (right).
- [ ] Estimate count uses correct singular/plural and shows "No estimates" for zero.
- [ ] "Recent Estimate" and "New Estimate" buttons are removed from the card footer.
- [ ] "Actions ▼" dropdown appears in the card footer; no "Details" link is present.
- [ ] Actions dropdown contains "Recent Estimate" and "New Estimate" items with equivalent behaviour to the removed buttons.

---

## Technical Context

- The estimates page (`/admin/estimates`) is the design reference. Styles, components, and class names from that page should be reused wherever possible.
- The total estimate count per customer will be sourced from the updated API response (`estimate_count` field) — see backend spec.

---

## UI/UX Notes

- The card header shading, background tint, and button styles should directly mirror the estimates page — no new design decisions are required.
- "Actions ▼" dropdown should use the same dropdown component as the estimates page.
- Singular/plural for estimate count: "1 estimate", "2 estimates", "No estimates".

---

## Edge Cases / Error Handling

- If `estimate_count` is 0, display "No estimates" rather than "0 estimates".
- If `estimate_count` is 1, display "1 estimate" (not "1 estimates").
- If the API returns an error, the existing error state behaviour should be preserved.

---

## Clarifying Questions

1. Is there an existing shared dropdown component used on the estimates page that should be reused here, or will a new one need to be created?
