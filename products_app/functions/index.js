const functions = require('firebase-functions');
const cors = require('cors')({ origin: true });
const Busboy = require('busboy');
const os = require('os');
const path = require('path');
const fs = require('fs');
const fbAdmin = require('firebase-admin');
const uuid = require('uuid/v4');

const gcconfig = {
  projectId: 'flutter-products-552d4',
  keyFilenme: 'flutter-products.json'
};

const { Storage } = require('@google-cloud/storage');
const gcs = new Storage(gcconfig);

fbAdmin.initializeApp({
  credential: fbAdmin.credential.cert(require('./flutter-products.json'))
});

exports.storeImage = functions.https.onRequest((request, response) => {
  return cors(request, response, () => {
    if (request.method !== 'POST') {
      return response.status(500).json({ message: 'Not allowed.' });
    }
    const { headers } = request;
    if (
      !headers.authorization ||
      !headers.authorization.startsWith('Bearer ')
    ) {
      return response.status(401).json({ error: 'Unauthorized.' });
    }

    const idToken = headers.authorization.replace('Bearer ', '');
    const busboy = new Busboy({ headers });

    let uploadData;
    let oldImagePath;

    busboy.on('file', (fieldname, file, filename, encoding, mimetype) => {
      const filePath = path.join(os.tmpdir(), filename);
      uploadData = { filePath, type: mimetype, name: filename };
      file.pipe(fs.createWriteStream(filePath));
    });

    busboy.on('field', (fieldname, value) => {
      oldImagePath = decodeURIComponent(value);
    });

    busboy.on('finish', () => {
      const bucket = gcs.bucket('flutter-products-552d4.appspot.com');
      const id = uuid();
      const imagePath = oldImagePath
        ? oldImagePath
        : `images/${id}-${uploadData.name}`;
      return fbAdmin
        .auth()
        .verifyIdToken(idToken)
        .then(decodedToken =>
          bucket.upload(uploadData.filePath, {
            uploadType: 'media',
            destination: imagePath,
            metadata: {
              metadata: {
                contentType: uploadData.type,
                firebaseStorageDownloadTokens: id
              }
            }
          })
        )
        .then(() =>
          response.status(201).json({
            imageUrl: `https://firebasestorage.googleapis.com/v0/b/${
              bucket.name
            }/o/${encodeURIComponent(imagePath)}?alt=media&token=${id}`,
            imagePath
          })
        )
        .catch(e => response.status(401).json({ error: 'Unauthorized.' }));
    });
    return busboy.end(request.rawBody);
  });
});

exports.deleteImage = functions.database
  .ref('/products/{productId}')
  .onDelete(snapshot => {
    const { imagePath = null } = snapshot.val();
    if (imagePath === null) return null;
    const bucket = gcs.bucket('flutter-products-552d4.appspot.com');
    return bucket.file(imagePath).delete();
  });
