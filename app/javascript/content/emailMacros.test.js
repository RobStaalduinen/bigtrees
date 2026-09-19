import { test } from 'node:test';
import assert from 'node:assert/strict';
import { MACRO_KEYS, expandBody, expandSubject } from './emailMacros.js';

function context(overrides = {}) {
  return {
    organization: { name: 'Big Trees', email_signature: 'Tyler\nBig Trees', ...overrides.organization },
    estimate: {
      customer_detail: { name: 'jane doe' },
      total_cost: 1200,
      total_cost_with_tax: 1356,
      job: null,
      ...overrides.estimate
    }
  };
}

test('expands the same macro in a subject and in a body', () => {
  const ctx = context();

  assert.equal(expandSubject('Your quote from [ORGANIZATION_NAME]', ctx), 'Your quote from Big Trees');
  assert.equal(expandBody('Thanks for choosing [ORGANIZATION_NAME].', ctx), 'Thanks for choosing Big Trees.');
});

test('expands customer and cost macros in a subject, which used to be organization-only', () => {
  const ctx = context();

  assert.equal(expandSubject('[FIRST_NAME], your quote is [TOTAL_COST]', ctx), 'Jane, your quote is 1200');
});

test('replaces every occurrence, not just the first', () => {
  const ctx = context();

  assert.equal(
    expandBody('Hi [FIRST_NAME], thanks [FIRST_NAME]. — [ORGANIZATION_NAME], [ORGANIZATION_NAME]', ctx),
    'Hi Jane, thanks Jane. — Big Trees, Big Trees'
  );
});

test('leaves nothing behind when a macro has no value', () => {
  const ctx = context({ organization: { email_signature: null } });

  assert.equal(expandBody('Regards,\n[SIGNATURE]', ctx), 'Regards,\n');
  assert.equal(expandBody('[ARBORIST_NOTES][FOLLOWUP]', ctx), '');
});

test('renders a customer name that is missing as empty, never as "undefined"', () => {
  const ctx = context({ estimate: { customer_detail: { name: null } } });

  assert.equal(expandBody('Hi [FIRST_NAME],', ctx), 'Hi ,');
});

test('does not treat $ in a value as a replacement pattern', () => {
  const ctx = context({ organization: { name: 'A$B & $& Trees' } });

  assert.equal(expandBody('[ORGANIZATION_NAME]', ctx), 'A$B & $& Trees');
});

test('includes the job paragraphs only when the job carries them', () => {
  const withJob = context({ estimate: { job: { completion_notes: 'All done.', followup_year: 2028 } } });

  assert.match(expandBody('[ARBORIST_NOTES]', withJob), /All done\./);
  assert.match(expandBody('[FOLLOWUP]', withJob), /2028/);
  assert.equal(expandBody('[ARBORIST_NOTES]', context()), '');
});

test('strips the retired content slot', () => {
  assert.equal(expandBody('before[ADDITIONAL_CONTENT_SLOT]after', context()), 'beforeafter');
});

test('flattens a subject so a multi-line macro cannot break the header', () => {
  const ctx = context({ estimate: { job: { completion_notes: 'Line one.\nLine two.', followup_year: null } } });

  const subject = expandSubject('Update: [ARBORIST_NOTES]', ctx);

  assert.ok(!subject.includes('\n'), `expected a single-line subject, got ${JSON.stringify(subject)}`);
  assert.equal(subject, 'Update: Below is also a word from the tree workers who completed your project: Line one. Line two.');
});

test('leaves an unknown placeholder untouched', () => {
  assert.equal(expandBody('[NOT_A_MACRO]', context()), '[NOT_A_MACRO]');
});

test('handles empty and missing input', () => {
  assert.equal(expandBody('', context()), '');
  assert.equal(expandBody(null, context()), '');
  assert.equal(expandSubject(undefined, context()), '');
});

test('every reserved key the server guards has a macro behind it', () => {
  // Mirrors EmailTemplate::RESERVED_KEYS — an organization cannot claim these as insertable keys
  // precisely because the macro table owns them.
  const reservedKeys = [
    'FIRST_NAME', 'SIGNATURE', 'TOTAL_COST', 'TOTAL_COST_WITH_TAX',
    'ARBORIST_NOTES', 'FOLLOWUP', 'ORGANIZATION_NAME', 'ADDITIONAL_CONTENT_SLOT'
  ];

  assert.deepEqual([...MACRO_KEYS].sort(), [...reservedKeys].sort());
});
