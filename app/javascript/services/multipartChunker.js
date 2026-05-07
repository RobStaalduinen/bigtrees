export function chunksFor(file, partSize) {
  const parts = [];
  let partNumber = 1;
  for (let start = 0; start < file.size; start += partSize) {
    const end = Math.min(start + partSize, file.size);
    parts.push({ partNumber, start, end, blob: file.slice(start, end) });
    partNumber++;
  }
  return parts;
}
