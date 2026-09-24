// Organization-defined insertable blocks. A template registers one by including its key in
// square brackets (e.g. [SCHEDULE_TEXT]); the form then renders a select of that insertable's
// options and splices the chosen text into the body as its own paragraph.

function placeholderPattern(key) {
  return new RegExp(`[ \\t]*\\[${key}\\][ \\t]*`, 'g');
}

// The insertables whose key actually appears in this template.
function findInsertables(content, insertables) {
  if (!content) { return []; }

  return (insertables || []).filter(insertable => content.includes(`[${insertable.key}]`));
}

// Strip trailing whitespace per line, collapse runs of blank lines to a single one, and trim.
function normalizeWhitespace(content) {
  return content
    .replace(/[ \t]+$/gm, '')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

// Insertables are block level: the replacement is always wrapped in blank lines and then
// normalized, so paragraph flow holds whether or not an option is selected.
function applyInsertables(content, insertables, selections = {}) {
  const present = findInsertables(content, insertables);
  if (present.length === 0) { return content; }

  let result = content;

  present.forEach(insertable => {
    const option = (insertable.options || []).find(o => o.id === selections[insertable.key]);
    const replacement = option ? `\n\n${option.content.trim()}\n\n` : '\n\n';

    result = result.replace(placeholderPattern(insertable.key), replacement);
  });

  return normalizeWhitespace(result);
}

export {
  findInsertables,
  normalizeWhitespace,
  applyInsertables
}
