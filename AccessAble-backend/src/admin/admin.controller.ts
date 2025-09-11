import { Controller, Get, UseGuards } from '@nestjs/common';
import { AdminService } from './admin.service';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/roles.decorator';

@Controller('admin')
@UseGuards(FirebaseAuthGuard, RolesGuard)
export class AdminController {
  constructor(private adminService: AdminService) {}

  @Get('dashboard')
  @Roles('admin')
  async getDashboardStats() {
    return this.adminService.getDashboardStats();
  }

  @Get('pending')
  @Roles('admin')
  async getPendingApprovals() {
    return this.adminService.getPendingApprovals();
  }
}