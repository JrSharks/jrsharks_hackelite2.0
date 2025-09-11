import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { UsersModule } from '../users/users.module';
import { PlacesModule } from '../places/places.module';
import { RolesGuard } from '../auth/guards/roles.guard';

@Module({
  imports: [UsersModule, PlacesModule],
  controllers: [AdminController],
  providers: [AdminService, RolesGuard],
})
export class AdminModule {}