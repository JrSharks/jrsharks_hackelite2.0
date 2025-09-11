import { FirebaseService } from '../firebase/firebase.service';
export declare class AuthService {
    private firebaseService;
    constructor(firebaseService: FirebaseService);
    validateUser(uid: string): Promise<{
        uid: string;
    }>;
    getUserProfile(uid: string): Promise<{
        uid: string;
    }>;
    updateUserProfile(uid: string, updateData: any): Promise<{
        uid: string;
    }>;
    createAdminUser(email: string, password: string, fullName: string): Promise<{
        uid: string;
        email: string;
        role: string;
    }>;
}
