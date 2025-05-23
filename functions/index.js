const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.createCustomToken = functions.https.onRequest(async (req, res) => {
  // CORS 설정
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  try {
    const { idToken } = req.body;
    
    if (!idToken) {
      res.status(400).json({ error: 'ID token is required' });
      return;
    }

    // Firebase ID Token 검증
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const uid = decodedToken.uid;

    // Custom Token 생성
    const customToken = await admin.auth().createCustomToken(uid);

    res.json({ customToken });
  } catch (error) {
    console.error('Error creating custom token:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}); 