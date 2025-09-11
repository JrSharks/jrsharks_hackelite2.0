import { Module } from '@nestjs/common';
import { PlacesController } from './places.controller';
import { PlacesService } from './places.service';
import { RolesGuard } from '../auth/guards/roles.guard';

@Module({
  controllers: [PlacesController],
  providers: [PlacesService, RolesGuard],
  exports: [PlacesService],
})
export class PlacesModule {}