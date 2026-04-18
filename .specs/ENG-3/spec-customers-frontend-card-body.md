# Spec: Customers Directory — Card Body Enhancements

**Jira Ticket:** [RST-XX](https://finlink.atlassian.net/browse/RST-XX)
**Date:** 2026-04-11
**Author:** Rob

---

## Overview

Following the structural redesign of the customers directory page, this spec covers the content changes to each customer card's body. The goal is to surface more useful contextual information — address, consolidated contact details, most recent estimate status, and last activity date — while cleaning up known data quality issues such as invalid phone number display.

---

## Goals

- Each customer card body displays a richer, more useful set of information for staff.
- Contact information is presented consistently with the estimates page.
- Customers with missing or invalid data are handled gracefully without surfacing raw bad data.

---

## Non-Goals / Out of Scope

- Changes to the card header or card actions (covered in the design alignment spec).
- Backend changes (covered in the backend API spec).
- Editing customer information from the directory page.

---

## Functional Requirements

1. **Address:** The customer's address must be displayed in the card body, on its own line, with a globe icon to its left — matching the icon and layout used on the estimates page. The address is sourced from an associated address record with `street`, `city`, and `postal_code` fields, and must be displayed as a single concatenated string in the format: "[street], [city], [postal_code]".

2. **Contact info layout:** Phone number and email address must be displayed on a single line, each preceded by its respective icon (phone icon, envelope icon), matching the estimates page layout.

3. **Phone number — invalid value handling:** If the customer's phone value is `null`, an empty string, or `"0"`, the phone number must be omitted from the card entirely. The email should still display normally on its own if phone is omitted.

4. **Last estimate status:** A line must be displayed below the contact info showing the status of the customer's most recent estimate, in the format: "Last estimate: [Status]" (e.g. "Last estimate: Quote Sent").

5. **Last activity date:** A line must be displayed below the last estimate status showing the `created_at` date of the most recent estimate, in the format: "Last active: [Date]" (e.g. "Last active: 12 Mar 2025").

6. **No estimates — omit estimate context lines:** If a customer has no estimates (`estimate_count` is 0), neither the "Last estimate" nor the "Last active" lines should be rendered.

7. **Line ordering in card body:** The card body content must appear in this order from top to bottom:
   1. Address (with globe icon)
   2. Phone + Email (on one line, with icons)
   3. Last estimate status
   4. Last activity date

---

## Acceptance Criteria

- [ ] Address is displayed as "[street], [city], [postal_code]" on its own line with a globe icon, for customers who have an associated address record.
- [ ] Phone and email appear on a single line with their respective icons.
- [ ] Phone values of `null`, `""`, or `"0"` result in the phone being omitted from the card; email still displays.
- [ ] "Last estimate: [Status]" line is displayed for customers with at least one estimate.
- [ ] "Last active: [Date]" line is displayed for customers with at least one estimate, using the estimate's `created_at` date formatted as "DD Mon YYYY" (e.g. "12 Mar 2025").
- [ ] Neither estimate context line is rendered for customers with zero estimates.
- [ ] Card body content follows the specified ordering.

---

## Technical Context

- `address`, `last_estimate_status`, `last_activity_date`, and `estimate_count` are all sourced from the updated customers list API response — see backend spec.
- Icons should reuse the same icon components/classes used on the estimates page for consistency.
- Date formatting for `last_activity_date` should use the application's existing date formatting utility if one exists.

---

## UI/UX Notes

- The address, phone, and email layout and icon style must mirror the estimates page exactly.
- "Last estimate" and "Last active" lines are plain text with a label prefix — no icons required.
- If a customer has no address on record, the address line should be omitted (do not render an empty row).
- If a customer has no email on record, the email should be omitted from the contact line.

---

## Edge Cases / Error Handling

| Scenario | Expected behaviour |
|---|---|
| Phone is `null`, `""`, or `"0"` | Omit phone; email still shows |
| No email on record | Omit email; phone still shows if valid |
| No address on record | Omit address row entirely |
| No estimates | Omit both "Last estimate" and "Last active" lines |
| Only one of phone/email present | Display the one that exists, no empty space for the missing one |

---

## Data Models, Schemas & Mapping

Fields consumed from the API response:

| Field | Type | Used for |
|---|---|---|
| `address` | string \| null | Address row |
| `phone` | string \| null | Contact line (omit if null or invalid) |
| `email` | string \| null | Contact line |
| `estimate_count` | integer | Determines whether to show estimate context lines |
| `last_estimate_status` | string \| null | "Last estimate:" line |
| `last_activity_date` | date string \| null | "Last active:" line |

---

## Clarifying Questions

1. What date format does the API return for `last_activity_date` (e.g. ISO 8601 `2025-03-12`)? Is there an existing frontend date formatting utility to convert this to "12 Mar 2025"?
2. Should estimate status labels be displayed exactly as returned by the API, or is there a frontend mapping/display name lookup?
