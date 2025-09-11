import { 
  Controller, 
  Get, 
  UseGuards, 
  Query, 
  Param, 
  Patch, 
  Delete,
  Body,
  ParseIntPipe,
  DefaultValuePipe,
  Request,
  NotFoundException,
  ForbiddenException 
} from '@nestjs/common';
import { UsersService, UpdateProfileDto } from './users.service';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/roles.decorator';

@Controller('users')
@UseGuards(FirebaseAuthGuard, RolesGuard)
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get()
  async getAllUsers(
    @Query('limit', new DefaultValuePipe(50), ParseIntPipe) limit: number,
    @Query('offset', new DefaultValuePipe(0), ParseIntPipe) offset: number,
  ) {
    return this.usersService.getAllUsers(limit, offset);
  }

  @Get('pending')
  @Roles('admin')
  async getPendingUsers() {
    return this.usersService.getPendingUsers();
  }

  @Get('stats')
  @Roles('admin')
  async getUserStats() {
    return this.usersService.getUserStats();
  }

  @Get(':uid')
  @Roles('admin')
  async getUserByUid(@Param('uid') uid: string) {
    const user = await this.usersService.getUserByUid(uid);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  @Patch(':uid/approve')
  @Roles('admin')
  async approveUser(@Param('uid') uid: string) {
    return this.usersService.approveUser(uid);
  }

  @Patch(':uid/role')
  @Roles('admin')
  async updateUserRole(
    @Param('uid') uid: string,
    @Body('role') role: string,
  ) {
    return this.usersService.updateUserRole(uid, role);
  }

  @Delete(':uid')
  @Roles('admin')
  async deleteUser(@Param('uid') uid: string) {
    await this.usersService.deleteUser(uid);
    return { message: 'User deleted successfully' };
  }

  @Get('search')
  async searchUsers(
    @Query('q') query: string = '',
    @Query('role') role?: string,
  ) {
    return this.usersService.searchUsers(query, role);
  }

  @Get(':uid/profile')
  async getUserProfile(@Param('uid') uid: string) {
    const user = await this.usersService.getUserByUid(uid);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  @Patch(':uid/profile')
  async updateProfile(
    @Param('uid') uid: string,
    @Body() updateData: UpdateProfileDto,
    @Request() req
  ) {
    // Users can only update their own profile, unless admin
    if (req.user.uid !== uid) {
      // Fetch role from Firestore to confirm admin
      const userProfile = await this.usersService.getUserByUid(req.user.uid);
      if (userProfile?.role !== 'admin') {
        throw new ForbiddenException('Unauthorized to update this profile');
      }
    }
    
    return this.usersService.updateProfile(uid, updateData);
  }

  @Get(':uid/submissions')
  async getUserSubmissions(@Param('uid') uid: string) {
    return this.usersService.getUserSubmissions(uid);
  }

  @Get(':uid/reviews')
  async getUserReviews(@Param('uid') uid: string) {
    return this.usersService.getUserReviews(uid);
  }

  @Patch(':uid/update-contributions')
  async updateUserContributions(@Param('uid') uid: string) {
    await this.usersService.updateUserContributionCount(uid);
    return { message: 'Contribution count updated successfully' };
  }
}