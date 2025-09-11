import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';

export interface UserProfile {
  uid: string;
  email: string;
  fullName: string;
  role: 'user' | 'caregiver' | 'business' | 'admin';
  isApproved: boolean;
  createdAt: any;
  updatedAt: any;
  contributionCount: number;
  reviewCount: number;
  accessibilityPreferences: {
    wheelchairAccessible: boolean;
    brailleSupport: boolean;
    hearingAssistance: boolean;
    visualAssistance: boolean;
  };
  profileImage?: string;
  bio?: string;
  location?: string;
}

export interface UpdateProfileDto {
  fullName?: string;
  bio?: string;
  location?: string;
  profileImage?: string;
  accessibilityPreferences?: {
    wheelchairAccessible?: boolean;
    brailleSupport?: boolean;
    hearingAssistance?: boolean;
    visualAssistance?: boolean;
  };
}

@Injectable()
export class UsersService {
  constructor(private firebaseService: FirebaseService) {}

  async getAllUsers(limit: number = 50, offset: number = 0): Promise<UserProfile[]> {
    const firestore = this.firebaseService.getFirestore();
    
    const snapshot = await firestore
      .collection('users')
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .offset(offset)
      .get();

    return snapshot.docs.map(doc => ({
      uid: doc.id,
      ...doc.data()
    })) as UserProfile[];
  }

  async getPendingUsers(): Promise<UserProfile[]> {
    const firestore = this.firebaseService.getFirestore();
    
    const snapshot = await firestore
      .collection('users')
      .where('isApproved', '==', false)
      .orderBy('createdAt', 'desc')
      .get();

    return snapshot.docs.map(doc => ({
      uid: doc.id,
      ...doc.data()
    })) as UserProfile[];
  }

  async getUserByUid(uid: string): Promise<UserProfile | null> {
    const firestore = this.firebaseService.getFirestore();
    const doc = await firestore.collection('users').doc(uid).get();
    
    if (!doc.exists) {
      return null;
    }

    return {
      uid: doc.id,
      ...doc.data()
    } as UserProfile;
  }

  async approveUser(uid: string): Promise<UserProfile> {
    const firestore = this.firebaseService.getFirestore();
    
    await firestore.collection('users').doc(uid).update({
      isApproved: true,
      updatedAt: new Date(),
    });

    return this.getUserByUid(uid);
  }

  async updateUserRole(uid: string, role: string): Promise<UserProfile> {
    const firestore = this.firebaseService.getFirestore();
    
    await firestore.collection('users').doc(uid).update({
      role,
      updatedAt: new Date(),
    });

    return this.getUserByUid(uid);
  }

  async deleteUser(uid: string): Promise<void> {
    const firestore = this.firebaseService.getFirestore();
    const auth = this.firebaseService.getAuth();
    
    // Delete from Firestore
    await firestore.collection('users').doc(uid).delete();
    
    // Delete from Firebase Auth
    try {
      await auth.deleteUser(uid);
    } catch (error) {
      console.error('Error deleting user from Auth:', error);
    }
  }

  async getUserStats(): Promise<any> {
    const firestore = this.firebaseService.getFirestore();
    
    const totalUsersSnapshot = await firestore.collection('users').count().get();
    const pendingUsersSnapshot = await firestore
      .collection('users')
      .where('isApproved', '==', false)
      .count()
      .get();

    return {
      totalUsers: totalUsersSnapshot.data().count,
      pendingUsers: pendingUsersSnapshot.data().count,
      approvedUsers: totalUsersSnapshot.data().count - pendingUsersSnapshot.data().count,
    };
  }

  async updateProfile(uid: string, updateData: UpdateProfileDto): Promise<UserProfile> {
    const firestore = this.firebaseService.getFirestore();
    
    const updatePayload: any = {
      ...updateData,
      updatedAt: new Date(),
    };

    // Merge accessibility preferences if provided
    if (updateData.accessibilityPreferences) {
      const currentUser = await this.getUserByUid(uid);
      updatePayload.accessibilityPreferences = {
        ...currentUser?.accessibilityPreferences,
        ...updateData.accessibilityPreferences,
      };
    }

    await firestore.collection('users').doc(uid).update(updatePayload);
    return this.getUserByUid(uid);
  }

  async getUserSubmissions(uid: string): Promise<any[]> {
    const firestore = this.firebaseService.getFirestore();
    
    const snapshot = await firestore
      .collection('places')
      .where('submittedBy', '==', uid)
      .orderBy('createdAt', 'desc')
      .get();

    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  }

  async getUserReviews(uid: string): Promise<any[]> {
    const firestore = this.firebaseService.getFirestore();
    
    // Get all places and filter reviews by user
    const placesSnapshot = await firestore.collection('places').get();
    const userReviews: any[] = [];

    placesSnapshot.docs.forEach(placeDoc => {
      const placeData = placeDoc.data();
      const reviews = placeData.reviews || [];
      
      reviews.forEach((review: any) => {
        if (review.userId === uid) {
          userReviews.push({
            ...review,
            placeId: placeDoc.id,
            placeName: placeData.name,
          });
        }
      });
    });

    return userReviews.sort((a, b) => 
      new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
    );
  }

  async updateUserContributionCount(uid: string): Promise<void> {
    const firestore = this.firebaseService.getFirestore();
    
    // Count user's places
    const placesCount = await firestore
      .collection('places')
      .where('submittedBy', '==', uid)
      .count()
      .get();

    // Count user's reviews
    const reviews = await this.getUserReviews(uid);
    const reviewCount = reviews.length;

    await firestore.collection('users').doc(uid).update({
      contributionCount: placesCount.data().count,
      reviewCount,
      updatedAt: new Date(),
    });
  }

  async searchUsers(query: string, role?: string): Promise<UserProfile[]> {
    const firestore = this.firebaseService.getFirestore();
    
    let usersQuery: any = firestore.collection('users');
    
    if (role) {
      usersQuery = usersQuery.where('role', '==', role);
    }

    const snapshot = await usersQuery.get();
    let users = snapshot.docs.map(doc => ({
      uid: doc.id,
      ...doc.data()
    })) as UserProfile[];

    // Filter by search query
    if (query) {
      const searchLower = query.toLowerCase();
      users = users.filter(user => 
        user.fullName.toLowerCase().includes(searchLower) ||
        user.email.toLowerCase().includes(searchLower) ||
        (user.location && user.location.toLowerCase().includes(searchLower))
      );
    }

    return users;
  }
}