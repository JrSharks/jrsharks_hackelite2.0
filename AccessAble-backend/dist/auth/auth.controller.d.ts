import { AuthService } from './auth.service';
export declare class AuthController {
    private authService;
    constructor(authService: AuthService);
    getProfile(req: any): Promise<{
        uid: string;
    }>;
    updateProfile(req: any, updateData: any): Promise<{
        uid: string;
    }>;
    verifyToken(req: any): Promise<{
        uid: any;
        email: any;
        verified: boolean;
        message: string;
    }>;
    createAdminUser(body: {
        email: string;
        password: string;
        fullName: string;
    }): Promise<{
        success: boolean;
        message: string;
        uid: string;
        email: string;
        error?: undefined;
    } | {
        success: boolean;
        message: string;
        error: any;
        uid?: undefined;
        email?: undefined;
    }>;
}
