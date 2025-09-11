# AccessAble Backend API

A NestJS backend service for the AccessAble platform, providing REST APIs for managing accessible places, user authentication, and admin functionality.

## Features

- 🔐 **Firebase Authentication Integration**
- 👥 **User Management & Approval Workflow**
- 📍 **Places Management with Accessibility Features**
- 🏛️ **Admin Dashboard & Content Moderation**
- 🔍 **Search & Filtering Capabilities**
- 📊 **Analytics & Reporting**
- 🛡️ **Security & Rate Limiting**

## Tech Stack

- **Framework**: NestJS
- **Database**: Firebase Firestore
- **Authentication**: Firebase Admin SDK
- **Language**: TypeScript
- **Validation**: class-validator
- **Documentation**: Auto-generated Swagger docs

## API Endpoints

### Authentication
- `GET /api/v1/auth/profile` - Get user profile
- `PATCH /api/v1/auth/profile` - Update user profile
- `GET /api/v1/auth/verify` - Verify token

### Users
- `GET /api/v1/users` - Get all users (paginated)
- `GET /api/v1/users/pending` - Get pending user approvals
- `GET /api/v1/users/stats` - Get user statistics
- `PATCH /api/v1/users/:uid/approve` - Approve user
- `PATCH /api/v1/users/:uid/role` - Update user role
- `DELETE /api/v1/users/:uid` - Delete user

### Places
- `GET /api/v1/places` - Get all places (with filters)
- `GET /api/v1/places/search` - Search places with accessibility filters
- `GET /api/v1/places/pending` - Get pending place approvals
- `POST /api/v1/places` - Create new place
- `POST /api/v1/places/:id/reviews` - Add review to place
- `PATCH /api/v1/places/:id/approve` - Approve place
- `PATCH /api/v1/places/:id` - Update place
- `DELETE /api/v1/places/:id` - Delete place

### Admin
- `GET /api/v1/admin/dashboard` - Get dashboard statistics
- `GET /api/v1/admin/pending` - Get all pending approvals

## Data Models

### User Profile
```typescript
{
  uid: string;
  email: string;
  fullName: string;
  role: 'user' | 'caregiver' | 'business' | 'admin';
  isApproved: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  contributionCount: number;
  accessibilityPreferences: {
    wheelchairAccessible: boolean;
    brailleSupport: boolean;
    hearingAssistance: boolean;
    visualAssistance: boolean;
  };
}
```

### Place
```typescript
{
  id: string;
  name: string;
  description: string;
  category: string;
  address: string;
  coordinates: { latitude: number; longitude: number; };
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
  createdAt: Timestamp;
  updatedAt: Timestamp;
  reviews: Review[];
  averageRating: number;
}
```

## Setup Instructions

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Environment Configuration**
   ```bash
   cp .env.example .env
   # Update .env with your Firebase credentials
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Enable Authentication and Firestore
   - Generate a service account key
   - Update environment variables

4. **Development**
   ```bash
   npm run start:dev
   ```

5. **Production**
   ```bash
   npm run build
   npm run start:prod
   ```

## Firebase Configuration

1. Go to Firebase Console
2. Create a new project
3. Enable Authentication (Email/Password, Google)
4. Enable Firestore Database
5. Enable Storage
6. Go to Project Settings > Service Accounts
7. Generate new private key
8. Update `.env` file with credentials

## Security Features

- **JWT Token Validation**: All protected routes validate Firebase tokens
- **Rate Limiting**: 100 requests per minute per IP
- **CORS Protection**: Configured for specific origins
- **Helmet Security**: Security headers enabled
- **Input Validation**: Request validation with class-validator
- **Role-based Access**: Different permissions for users and admins

## Deployment

The backend can be deployed to:
- **Heroku**: Easy deployment with buildpacks
- **Google Cloud Run**: Serverless containers
- **AWS ECS/Lambda**: Scalable cloud deployment
- **DigitalOcean App Platform**: Simple deployment

## Contributing

1. Follow NestJS best practices
2. Use TypeScript strictly
3. Add proper error handling
4. Include unit tests for services
5. Update documentation for new endpoints

## License

Private - AccessAble Platform