import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private firebaseApp: admin.app.App;

  constructor(private configService: ConfigService) {}

  async onModuleInit() {
    // Initialize Firebase Admin SDK
    const serviceAccount = {
      projectId: this.configService.get('FIREBASE_PROJECT_ID'),
      privateKey: this.configService.get('FIREBASE_PRIVATE_KEY')?.replace(/\\n/g, '\n'),
      clientEmail: this.configService.get('FIREBASE_CLIENT_EMAIL'),
    };

    this.firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      storageBucket: this.configService.get('FIREBASE_STORAGE_BUCKET'),
    });

    console.log('✅ Firebase Admin SDK initialized successfully');
  }

  getFirebaseApp(): admin.app.App {
    return this.firebaseApp;
  }

  getAuth(): admin.auth.Auth {
    return admin.auth(this.firebaseApp);
  }

  getFirestore(): admin.firestore.Firestore {
    return admin.firestore(this.firebaseApp);
  }

  getStorage(): admin.storage.Storage {
    return admin.storage(this.firebaseApp);
  }

  async verifyIdToken(idToken: string): Promise<admin.auth.DecodedIdToken> {
    try {
      return await this.getAuth().verifyIdToken(idToken);
    } catch (error) {
      throw new Error(`Invalid token: ${error.message}`);
    }
  }

  async getUserByUid(uid: string): Promise<admin.auth.UserRecord> {
    try {
      return await this.getAuth().getUser(uid);
    } catch (error) {
      throw new Error(`User not found: ${error.message}`);
    }
  }

  async createCustomToken(uid: string, additionalClaims?: object): Promise<string> {
    try {
      return await this.getAuth().createCustomToken(uid, additionalClaims);
    } catch (error) {
      throw new Error(`Failed to create custom token: ${error.message}`);
    }
  }
}