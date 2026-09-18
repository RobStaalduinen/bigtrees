// One entry per point in the workflow an email is sent from — mirrors EmailTemplate::CATEGORIES
// and its ordering. Every template belongs to exactly one of these, and each send form offers the
// templates of the step it sits on.
//
// `endpoint` is where the Send Customer Email sidebar posts a template of this category. It is a
// resend, so categories whose own endpoint carries side effects (issuing the invoice, recording
// payment) fall back to quote_mailouts, which only sends and records.
const EMAIL_CATEGORIES = [
  {
    key: 'quote',
    label: 'Quote',
    description: 'Sent with the quote when a price goes out to the customer.',
    endpoint: 'quote_mailouts'
  },
  {
    key: 'followup',
    label: 'Followup',
    description: 'Sent by hand to chase a customer who has not replied yet.',
    endpoint: 'followups'
  },
  {
    key: 'approval',
    label: 'Approval',
    description: 'Sent once the customer has approved the work.',
    endpoint: 'approval_mailouts'
  },
  {
    key: 'scheduling',
    label: 'Scheduling',
    description: "Sent as the job's scheduled date approaches.",
    endpoint: 'scheduling_mailouts'
  },
  {
    key: 'job_progress',
    label: 'Job Progress',
    description: 'Sent when part of the job is done and work carries on another day.',
    endpoint: 'job_progress_mailouts'
  },
  {
    key: 'invoice',
    label: 'Invoice',
    description: 'Sent with the final invoice once the work is finished.',
    endpoint: 'quote_mailouts'
  },
  {
    key: 'receipt',
    label: 'Receipt',
    description: 'Sent once payment has been recorded.',
    endpoint: 'quote_mailouts'
  }
];

// Estimate statuses in pipeline order (mirrors the Estimate#status enum).
const STATUS_ORDER = [
  'needs_costs', 'needs_arborist', 'pending_quote', 'quote_sent',
  'approved', 'work_scheduled', 'work_started', 'work_paused',
  'work_completed', 'final_invoice_sent', 'completed'
];

const atLeast = (status, threshold) =>
  STATUS_ORDER.indexOf(status) >= STATUS_ORDER.indexOf(threshold);

// Resending a workflow email only makes sense once the estimate has reached that step. Followup
// and scheduling emails are sent at the operator's discretion, so they carry no rule.
const CATEGORY_STATUS_RULES = {
  quote: status => atLeast(status, 'quote_sent'),
  approval: status => atLeast(status, 'approved'),
  job_progress: status => ['work_paused', 'work_completed'].includes(status),
  invoice: status => atLeast(status, 'final_invoice_sent'),
  receipt: status => status === 'completed'
};

function categoryLabelFor(key) {
  const category = categoryFor(key);

  return category ? category.label : key;
}

// Position in the workflow, used to sort a mixed list of templates into pipeline order.
function categoryOrder(key) {
  const index = EMAIL_CATEGORIES.findIndex(category => category.key === key);

  return index === -1 ? EMAIL_CATEGORIES.length : index;
}

function categoryFor(key) {
  return EMAIL_CATEGORIES.find(category => category.key === key);
}

function categoryAvailable(key, status) {
  const rule = CATEGORY_STATUS_RULES[key];

  return rule ? rule(status) : true;
}

// Templates are identified by key alone, so their labels are humanized from it.
function formatTemplateKey(key) {
  return key.replace(/_/g, ' ').replace(/\b\w/g, char => char.toUpperCase());
}

export {
  EMAIL_CATEGORIES,
  categoryFor,
  categoryLabelFor,
  categoryOrder,
  categoryAvailable,
  formatTemplateKey
}
