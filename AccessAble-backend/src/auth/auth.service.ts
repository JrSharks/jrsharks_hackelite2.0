import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';

@Injectable()
export class AuthService {
  constructor(private firebaseService: FirebaseService) {}

  async validateUser(uid: string) {
    const firestore = this.firebaseService.getFirestore();
    const userDoc = await firestore.collection('users').doc(uid).get();
    
    if (!userDoc.exists) {
      return null;
    }

    const userData = userDoc.data();
    return {
      uid,
      ...userData,
    };
  }

  async getUserProfile(uid: string) {
    const firestore = this.firebaseService.getFirestore();
    const userDoc = await firestore.collection('users').doc(uid).get();
    
    if (!userDoc.exists) {
      throw new Error('User profile not found');
    }

    return {
      uid,
      ...userDoc.data(),
    };
  }

  async updateUserProfile(uid: string, updateData: any) {
    const firestore = this.firebaseService.getFirestore();
    
    await firestore.collection('users').doc(uid).update({
      ...updateData,
      updatedAt: new Date(),
    });

    return this.getUserProfile(uid);
  }

  // TEMPORARY: Remove this method after creating admin user
  async createAdminUser(email: string, password: string, fullName: string) {
    const auth = this.firebaseService.getAuth();
    const firestore = this.firebaseService.getFirestore();

    try {
      // Create user in Firebase Auth
      const userRecord = await auth.createUser({
        email,
        password,
        emailVerified: true,
      });

      // Create user document in Firestore with admin role
      const adminUserData = {
        uid: userRecord.uid,
        email: userRecord.email,
        fullName,
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

      await firestore.collection('users').doc(userRecord.uid).set(adminUserData);

      return {
        uid: userRecord.uid,
        email: userRecord.email,
        role: 'admin'
      };
    } catch (error) {
      throw new Error(`Failed to create admin user: ${error.message}`);
    }
  }
}