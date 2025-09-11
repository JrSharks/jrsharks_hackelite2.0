import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';
import { v4 as uuidv4 } from 'uuid';

export interface Place {
  id: string;
  name: string;
  description: string;
  category: string;
  address: string;
  coordinates: {
    latitude: number;
    longitude: number;
  };
  accessibilityFeatures: {
    wheelchairAccessible: boolean;
    brailleSupport: boolean;
    hearingAssistance: boolean;
    visualAssistance: boolean;
    accessibleParking: boolean;
    accessibleRestroom: boolean;
    elevatorAccess: boolean;
    rampAccess: boolean;
  };
  photos: string[];
  submittedBy: string;
  isApproved: boolean;
  createdAt: any;
  updatedAt: any;
  reviews: Review[];
  averageRating: number;
}

export interface Review {
  id: string;
  userId: string;
  userName: string;
  rating: number;
  comment: string;
  accessibilityRating: number;
  createdAt: any;
}

export interface CreatePlaceDto {
  name: string;
  description: string;
  category: string;
  address: string;
  coordinates: {
    latitude: number;
    longitude: number;
  };
  accessibilityFeatures: {
    wheelchairAccessible: boolean;
    brailleSupport: boolean;
    hearingAssistance: boolean;
    visualAssistance: boolean;
    accessibleParking: boolean;
    accessibleRestroom: boolean;
    elevatorAccess: boolean;
    rampAccess: boolean;
  };
  photos?: string[];
}

@Injectable()
export class PlacesService {
  constructor(private firebaseService: FirebaseService) {}

  async createPlace(createPlaceDto: CreatePlaceDto, submittedBy: string): Promise<Place> {
    const firestore = this.firebaseService.getFirestore();
    const placeId = uuidv4();

    const placeData: Omit<Place, 'id'> = {
      ...createPlaceDto,
      photos: createPlaceDto.photos || [],
      submittedBy,
      isApproved: false,
      createdAt: new Date(),
      updatedAt: new Date(),
      reviews: [],
      averageRating: 0,
    };

    await firestore.collection('places').doc(placeId).set(placeData);

    return {
      id: placeId,
      ...placeData,
    };
  }

  async getAllPlaces(approved: boolean = true, limit: number = 50, offset: number = 0): Promise<Place[]> {
    const firestore = this.firebaseService.getFirestore();
    
    let query = firestore.collection('places').orderBy('createdAt', 'desc');
    
    if (approved !== undefined) {
      query = query.where('isApproved', '==', approved);
    }

    const snapshot = await query.limit(limit).offset(offset).get();

    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    })) as Place[];
  }

  async getPlaceById(id: string): Promise<Place | null> {
    const firestore = this.firebaseService.getFirestore();
    const doc = await firestore.collection('places').doc(id).get();
    
    if (!doc.exists) {
      return null;
    }

    return {
      id: doc.id,
      ...doc.data()
    } as Place;
  }

  async getPendingPlaces(): Promise<Place[]> {
    return this.getAllPlaces(false);
  }

  async approvePlace(id: string): Promise<Place> {
    const firestore = this.firebaseService.getFirestore();
    
    await firestore.collection('places').doc(id).update({
      isApproved: true,
      updatedAt: new Date(),
    });

    return this.getPlaceById(id);
  }

  async updatePlace(id: string, updateData: Partial<Place>): Promise<Place> {
    const firestore = this.firebaseService.getFirestore();
    
    await firestore.collection('places').doc(id).update({
      ...updateData,
      updatedAt: new Date(),
    });

    return this.getPlaceById(id);
  }

  async deletePlace(id: string): Promise<void> {
    const firestore = this.firebaseService.getFirestore();
    await firestore.collection('places').doc(id).delete();
  }

  async addReview(placeId: string, review: Omit<Review, 'id' | 'createdAt'>): Promise<Place> {
    const firestore = this.firebaseService.getFirestore();
    const reviewId = uuidv4();

    const reviewData: Review = {
      id: reviewId,
      ...review,
      createdAt: new Date(),
    };

    // Get current place data
    const place = await this.getPlaceById(placeId);
    if (!place) {
      throw new Error('Place not found');
    }

    // Add review and recalculate average rating
    const updatedReviews = [...place.reviews, reviewData];
    const averageRating = updatedReviews.reduce((sum, r) => sum + r.rating, 0) / updatedReviews.length;

    await firestore.collection('places').doc(placeId).update({
      reviews: updatedReviews,
      averageRating,
      updatedAt: new Date(),
    });

    return this.getPlaceById(placeId);
  }

  async searchPlaces(query: string, filters?: any): Promise<Place[]> {
    const firestore = this.firebaseService.getFirestore();
    
    // Basic text search (in a real app, you'd use Algolia or Elasticsearch)
    let placesQuery = firestore
      .collection('places')
      .where('isApproved', '==', true);

    if (filters?.category) {
      placesQuery = placesQuery.where('category', '==', filters.category);
    }

    const snapshot = await placesQuery.get();
    let places = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    })) as Place[];

    // Filter by search query
    if (query) {
      const searchLower = query.toLowerCase();
      places = places.filter(place => 
        place.name.toLowerCase().includes(searchLower) ||
        place.description.toLowerCase().includes(searchLower) ||
        place.address.toLowerCase().includes(searchLower)
      );
    }

    // Filter by accessibility features
    if (filters?.accessibility) {
      Object.keys(filters.accessibility).forEach(feature => {
        if (filters.accessibility[feature]) {
          places = places.filter(place => place.accessibilityFeatures[feature]);
        }
      });
    }

    // Filter by location radius if provided
    if (filters?.location && filters?.radius) {
      places = places.filter(place => {
        const distance = this.calculateDistance(
          filters.location.latitude,
          filters.location.longitude,
          place.coordinates.latitude,
          place.coordinates.longitude
        );
        return distance <= filters.radius; // radius in meters
      });
    }

    // Sort by distance if location provided
    if (filters?.location) {
      places.sort((a, b) => {
        const distanceA = this.calculateDistance(
          filters.location.latitude,
          filters.location.longitude,
          a.coordinates.latitude,
          a.coordinates.longitude
        );
        const distanceB = this.calculateDistance(
          filters.location.latitude,
          filters.location.longitude,
          b.coordinates.latitude,
          b.coordinates.longitude
        );
        return distanceA - distanceB;
      });

      // Add distance to each place
      places = places.map(place => ({
        ...place,
        distance: this.calculateDistance(
          filters.location.latitude,
          filters.location.longitude,
          place.coordinates.latitude,
          place.coordinates.longitude
        )
      }));
    }

    // Sort by rating if no location provided
    if (!filters?.location) {
      places.sort((a, b) => (b.averageRating || 0) - (a.averageRating || 0));
    }

    return places;
  }

  private calculateDistance(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number
  ): number {
    const R = 6371e3; // Earth's radius in meters
    const φ1 = (lat1 * Math.PI) / 180;
    const φ2 = (lat2 * Math.PI) / 180;
    const Δφ = ((lat2 - lat1) * Math.PI) / 180;
    const Δλ = ((lon2 - lon1) * Math.PI) / 180;

    const a =
      Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
      Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c; // Distance in meters
  }

  async getPlaceStats(): Promise<any> {
    const firestore = this.firebaseService.getFirestore();
    
    const totalPlacesSnapshot = await firestore.collection('places').count().get();
    const pendingPlacesSnapshot = await firestore
      .collection('places')
      .where('isApproved', '==', false)
      .count()
      .get();

    return {
      totalPlaces: totalPlacesSnapshot.data().count,
      pendingPlaces: pendingPlacesSnapshot.data().count,
      approvedPlaces: totalPlacesSnapshot.data().count - pendingPlacesSnapshot.data().count,
    };
  }
}