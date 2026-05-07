export function signedUrlFormData(urlFields, imageFile) {
  const formData = new FormData();
  for ( var key in urlFields ) {
      formData.append(key, urlFields[key]);
  }

  formData.append('file', imageFile);

  return formData;
}

export class XmlParseError extends Error {
  constructor(message) { super(message); this.name = 'XmlParseError'; }
}

export function parseImageUploadResponse(response) {
  var parseString = require('xml2js').parseString;

  var imageUrl = null;
  var parseErr = null;
  parseString(response.data, (err, result) => {
    if (err || !result?.PostResponse?.Location?.[0]) {
      parseErr = err || new Error('Missing Location in S3 XML response');
      return;
    }
    imageUrl = result.PostResponse.Location[0];
  });

  if (parseErr) throw new XmlParseError(`S3 response parse failed: ${parseErr.message}`);
  return imageUrl;
}
