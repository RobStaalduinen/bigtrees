export function breadcrumb(category, message, data) {
  if (process.env.NODE_ENV !== 'production') {
    console.debug(`[${category}] ${message}`, data);
  }
  // TODO: Sentry.addBreadcrumb when @sentry/vue is wired
}

export function captureException(err, ctx) {
  console.error('[upload-error]', err, ctx);
  // TODO: Sentry.captureException when @sentry/vue is wired
}
