export function signedUrlFormData(urlFields, imageFile) {
  const formData = new FormData();
  for ( var key in urlFields ) {
      formData.append(key, urlFields[key]);
  }

  formData.append('file', imageFile);

  return formData;
}

export function parseImageUploadResponse(response) {
  var parseString = require('xml2js').parseString;

  var imageUrl = null;
  parseString(response.data, (err, result) => {
    imageUrl = result.PostResponse.Location[0];
  });
  return imageUrl;
}
