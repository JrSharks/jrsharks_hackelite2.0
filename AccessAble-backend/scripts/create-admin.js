const admin = require('firebase-admin');
const fs = require('fs');

// Initialize Firebase Admin using GOOGLE_APPLICATION_CREDENTIALS or inline JSON via env FIREBASE_SERVICE_ACCOUNT
function initAdmin() {
  try {
    const inlineJson = process.env.FIREBASE_SERVICE_ACCOUNT;
    if (inlineJson) {
      const creds = JSON.parse(inlineJson);
      admin.initializeApp({
        credential: admin.credential.cert(creds),
      });
      return;
    }

    const credsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
    if (credsPath && fs.existsSync(credsPath)) {
      const creds = require(credsPath);
      admin.initializeApp({
        credential: admin.credential.cert(creds),
      });
      return;
    }

    console.error('❌ No Firebase credentials found. Set FIREBASE_SERVICE_ACCOUNT or GOOGLE_APPLICATION_CREDENTIALS');
    process.exit(1);
  } catch (e) {
    console.error('❌ Failed to initialize Firebase Admin:', e.message);
    process.exit(1);
  }
}

initAdmin();

const db = admin.firestore();

async function createAdminUser(email, uid) {
  try {
    // Create user document in Firestore
    const adminUserData = {
      uid: uid,
      email: email,
      fullName: 'Admin User',
      role: 'admin',
      isApproved: true,
      createdAt: new Date(),
      updatedAt: new Date(),
      contributionCount: 0,
      reviewCount: 0,
      accessibilityPreferences: {
        wheelchairAccessible: false,
        brailleSupport: false,
        hearingAssistance: false,
        visualAssistance: false,
      },
      bio: 'System Administrator',
      location: 'Admin Panel',
    };

    await db.collection('users').doc(uid).set(adminUserData);
    
    console.log('✅ Admin user created successfully!');
    console.log('📧 Email:', email);
    console.log('🆔 UID:', uid);
    console.log('🔑 Role: admin');
    console.log('✅ Approved: true');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating admin user:', error);
    process.exit(1);
  }
}

// Get command line arguments
const args = process.argv.slice(2);
if (args.length < 2) {
  console.log('Usage: node create-admin.js <email> <uid>');
  console.log('Example: node create-admin.js admin@accessable.com abc123def456');
  console.log('');
  console.log('Steps:');
  console.log('1. Go to Firebase Console → Authentication → Users');
  console.log('2. Click "Add user" and create user with email/password');
  console.log('3. Copy the UID from the user list');
  console.log('4. Run this script with email and UID');
  process.exit(1);
}

const email = args[0];
const uid = args[1];

createAdminUser(email, uid);