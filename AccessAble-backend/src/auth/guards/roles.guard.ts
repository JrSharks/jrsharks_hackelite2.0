import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { FirebaseService } from '../../firebase/firebase.service';
import { ROLES_KEY } from '../roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private firebaseService: FirebaseService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user?.uid) {
      throw new ForbiddenException('Unauthorized');
    }

    // Fetch role from Firestore (source of truth)
    const firestore = this.firebaseService.getFirestore();
    const userDoc = await firestore.collection('users').doc(user.uid).get();
    const userRole = (userDoc.exists && (userDoc.data() as any)?.role) || 'user';

    if (!requiredRoles.includes(userRole)) {
      throw new ForbiddenException('Insufficient role');
    }

    return true;
  }
}


