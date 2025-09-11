import { Injectable } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { PlacesService } from '../places/places.service';

@Injectable()
export class AdminService {
  constructor(
    private usersService: UsersService,
    private placesService: PlacesService,
  ) {}

  async getDashboardStats() {
    const [userStats, placeStats] = await Promise.all([
      this.usersService.getUserStats(),
      this.placesService.getPlaceStats(),
    ]);

    return {
      users: userStats,
      places: placeStats,
      overview: {
        totalUsers: userStats.totalUsers,
        pendingApprovals: userStats.pendingUsers + placeStats.pendingPlaces,
        totalPlaces: placeStats.totalPlaces,
        systemHealth: 'healthy',
      }
    };
  }

  async getPendingApprovals() {
    const [pendingUsers, pendingPlaces] = await Promise.all([
      this.usersService.getPendingUsers(),
      this.placesService.getPendingPlaces(),
    ]);

    return {
      pendingUsers,
      pendingPlaces,
      totalPending: pendingUsers.length + pendingPlaces.length,
    };
  }
}