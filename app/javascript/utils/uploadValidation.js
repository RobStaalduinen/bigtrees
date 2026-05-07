const IN_FLIGHT = new Set(['compressing', 'preparing', 'uploading', 'finalizing']);

export function uploadGuard(images) {
  if (!images.length) {
    return { ok: false, message: 'Please add at least one image.' };
  }
  const errored = images.filter(i => i.status === 'retryableError' || i.status === 'fatalError');
  if (errored.length) {
    return { ok: false, message: `${errored.length} image(s) failed to upload — retry or remove them before saving.` };
  }
  const inflight = images.filter(i => IN_FLIGHT.has(i.status));
  if (inflight.length) {
    return { ok: false, message: 'Wait for image uploads to finish and try again.' };
  }
  return { ok: true, message: null };
}
