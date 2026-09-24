// Copy for the placeholder reference shown beside the email template form.
//
// The *set* of predefined placeholders is the server's (EmailTemplate::RESERVED_KEYS, handed over
// by the email insertables index); this file only supplies what each one means, so a key added
// server-side still appears here — just without a description. What each one expands to is in
// content/emailMacros.js, and every one of them works in the subject and the body alike.
const PLACEHOLDER_DETAILS = {
  FIRST_NAME: { description: "The customer's first name." },
  SIGNATURE: { description: "Your organization's email signature." },
  TOTAL_COST: { description: 'The quoted total, before tax.' },
  TOTAL_COST_WITH_TAX: { description: 'The quoted total, including tax.' },
  ARBORIST_NOTES: { description: "The crew's completion notes, when the job has them." },
  FOLLOWUP: { description: 'A follow-up visit paragraph, when the job has a follow-up year.' },
  ORGANIZATION_NAME: { description: "Your organization's name." }
};

// Still reserved so it cannot be reused as an insertable key, but no longer substituted into
// anything — it is stripped on send, so there is no reason to offer it.
const RETIRED_PLACEHOLDERS = ['ADDITIONAL_CONTENT_SLOT'];

function placeholderToken(key) {
  return `[${key}]`;
}

// The predefined placeholders an organization can use, in the order the server lists them.
function predefinedPlaceholders(reservedKeys = []) {
  return reservedKeys
    .filter(key => !RETIRED_PLACEHOLDERS.includes(key))
    .map(key => {
      const details = PLACEHOLDER_DETAILS[key] || {};

      return {
        key: key,
        token: placeholderToken(key),
        description: details.description || null
      }
    });
}

// The organization's own insertables, which the send form turns into a dropdown of options.
function insertablePlaceholders(insertables = []) {
  return insertables.map(insertable => ({
    key: insertable.key,
    token: placeholderToken(insertable.key),
    description: insertable.label,
    optionCount: (insertable.options || []).length
  }));
}

export {
  placeholderToken,
  predefinedPlaceholders,
  insertablePlaceholders
}
