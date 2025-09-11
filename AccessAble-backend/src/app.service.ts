import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHealth(): object {
    return {
      message: 'AccessAble Backend API is running!',
      status: 'healthy',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
      endpoints: {
        auth: '/api/v1/auth',
        users: '/api/v1/users', 
        places: '/api/v1/places',
        admin: '/api/v1/admin',
      }
    };
  }
}