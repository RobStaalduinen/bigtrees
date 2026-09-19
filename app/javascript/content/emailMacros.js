// The macro table for email templates.
//
// Every macro resolves against the organization and the estimate the email is being sent for, and
// expands identically in a subject and in a body — adding an entry here is all it takes to make a
// macro available in both. Keep the keys in step with EmailTemplate::RESERVED_KEYS, which stops an
// organization claiming one of them as an insertable key.
//
// Insertables ([SCHEDULE_TEXT] and friends) are not macros: they are block-level paragraphs chosen
// from a dropdown at send time, and live in content/emailInsertables.js.

function firstName(estimate) {
  const name = estimate?.customer_detail?.name;

  if (name == null) { return ''; }

  const first = name.trim().split(' ')[0];

  return first.charAt(0).toUpperCase() + first.slice(1);
}

function arboristNotes(estimate) {
  const notes = estimate?.job?.completion_notes;

  if (notes == null) { return ''; }

  return `\nBelow is also a word from the tree workers who completed your project:\n${notes}\n`;
}

function followup(estimate) {
  const year = estimate?.job?.followup_year;

  if (year == null) { return ''; }

  return `\nOur team has recommend we complete a follow up site visit in ${year}. Would you mind if we reach out to you down the road to schedule another no cost site visit?\n`;
}

const MACROS = {
  FIRST_NAME: ({ estimate }) => firstName(estimate),
  SIGNATURE: ({ organization }) => organization?.email_signature,
  TOTAL_COST: ({ estimate }) => estimate?.total_cost,
  TOTAL_COST_WITH_TAX: ({ estimate }) => estimate?.total_cost_with_tax,
  ARBORIST_NOTES: ({ estimate }) => arboristNotes(estimate),
  FOLLOWUP: ({ estimate }) => followup(estimate),
  ORGANIZATION_NAME: ({ organization }) => organization?.name,
  // Retired in favour of the SCHEDULE_TEXT insertable, but still stripped in case a template
  // written before the switch still carries it.
  ADDITIONAL_CONTENT_SLOT: () => ''
};

const MACRO_KEYS = Object.keys(MACROS);

// Replaces every occurrence, and resolves through a function so a value containing '$' is not
// read as a replacement pattern.
function expandMacro(text, key, value) {
  return text.replace(new RegExp(`\\[${key}\\]`, 'g'), () => value);
}

// A macro with nothing behind it (no signature set, no completion notes) leaves no trace.
function resolve(key, context) {
  const value = MACROS[key](context);

  return value == null ? '' : String(value);
}

// Expands every macro in an email body.
function expandBody(text, context) {
  if (!text) { return ''; }

  return MACRO_KEYS.reduce((result, key) => expandMacro(result, key, resolve(key, context)), text);
}

// Expands every macro in a subject line, then flattens it. Some macros carry whole paragraphs, and
// a subject that runs onto a second line is mangled in transit.
function expandSubject(text, context) {
  return expandBody(text, context).replace(/\s+/g, ' ').trim();
}

export {
  MACRO_KEYS,
  expandBody,
  expandSubject
}
