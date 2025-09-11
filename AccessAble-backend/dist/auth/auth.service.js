"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const firebase_service_1 = require("../firebase/firebase.service");
let AuthService = class AuthService {
    constructor(firebaseService) {
        this.firebaseService = firebaseService;
    }
    async validateUser(uid) {
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
    async getUserProfile(uid) {
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
    async updateUserProfile(uid, updateData) {
        const firestore = this.firebaseService.getFirestore();
        await firestore.collection('users').doc(uid).update({
            ...updateData,
            updatedAt: new Date(),
        });
        return this.getUserProfile(uid);
    }
    async createAdminUser(email, password, fullName) {
        const auth = this.firebaseService.getAuth();
        const firestore = this.firebaseService.getFirestore();
        try {
            const userRecord = await auth.createUser({
                email,
                password,
                emailVerified: true,
            });
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
        }
        catch (error) {
            throw new Error(`Failed to create admin user: ${error.message}`);
        }
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [firebase_service_1.FirebaseService])
], AuthService);
//# sourceMappingURL=auth.service.js.map