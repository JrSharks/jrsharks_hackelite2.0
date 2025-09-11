import { 
  Controller, 
  Get, 
  Post, 
  Patch, 
  Delete, 
  Body, 
  Param, 
  Query, 
  UseGuards, 
  Request,
  ParseIntPipe,
  DefaultValuePipe,
  NotFoundException 
} from '@nestjs/common';
import { PlacesService, CreatePlaceDto } from './places.service';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/roles.decorator';

@Controller('places')
export class PlacesController {
  constructor(private placesService: PlacesService) {}

  @Get()
  async getAllPlaces(
    @Query('approved') approved?: string,
    @Query('limit', new DefaultValuePipe(50), ParseIntPipe) limit: number = 50,
    @Query('offset', new DefaultValuePipe(0), ParseIntPipe) offset: number = 0,
  ) {
    const isApproved = approved === 'false' ? false : true;
    return this.placesService.getAllPlaces(isApproved, limit, offset);
  }

  @Get('search')
  async searchPlaces(
    @Query('q') query: string = '',
    @Query('category') category?: string,
    @Query('wheelchair') wheelchair?: boolean,
    @Query('braille') braille?: boolean,
    @Query('hearing') hearing?: boolean,
    @Query('visual') visual?: boolean,
    @Query('lat') latitude?: number,
    @Query('lng') longitude?: number,
    @Query('radius') radius?: number,
  ) {
    const filters = {
      category,
      accessibility: {
        wheelchairAccessible: wheelchair,
        brailleSupport: braille,
        hearingAssistance: hearing,
        visualAssistance: visual,
      },
      location: latitude && longitude ? { latitude, longitude } : null,
      radius: radius || 5000, // Default 5km radius
    };

    return this.placesService.searchPlaces(query, filters);
  }

  @Get('nearby')
  async getNearbyPlaces(
    @Query('lat') latitude: number,
    @Query('lng') longitude: number,
    @Query('radius', new DefaultValuePipe(2000), ParseIntPipe) radius: number = 2000,
    @Query('category') category?: string,
  ) {
    const filters = {
      category,
      location: { latitude, longitude },
      radius,
    };

    return this.placesService.searchPlaces('', filters);
  }

  @Get('recommendations')
  @UseGuards(FirebaseAuthGuard)
  async getRecommendations(@Request() req) {
    // Get user's accessibility preferences
    // This would be implemented with more sophisticated recommendation logic
    const userPreferences = req.user.accessibilityPreferences || {};
    
    const filters = {
      accessibility: userPreferences,
    };

    const places = await this.placesService.searchPlaces('', filters);
    return places.slice(0, 10); // Return top 10 recommendations
  }

  @Get('pending')
  @UseGuards(FirebaseAuthGuard)
  async getPendingPlaces() {
    return this.placesService.getPendingPlaces();
  }

  @Get('stats')
  async getPlaceStats() {
    return this.placesService.getPlaceStats();
  }

  @Get('map-data')
  async getMapData() {
    // Optimized endpoint for map display - returns only essential data
    const places = await this.placesService.getAllPlaces(true, 1000, 0);
    
    return places.map(place => ({
      id: place.id,
      name: place.name,
      category: place.category,
      coordinates: place.coordinates,
      accessibilityFeatures: place.accessibilityFeatures,
      averageRating: place.averageRating,
      reviewCount: place.reviews?.length || 0
    }));
  }

  @Get(':id')
  async getPlaceById(@Param('id') id: string) {
    const place = await this.placesService.getPlaceById(id);
    if (!place) {
      throw new NotFoundException('Place not found');
    }
    return place;
  }

  @Post()
  @UseGuards(FirebaseAuthGuard)
  async createPlace(@Body() createPlaceDto: CreatePlaceDto, @Request() req) {
    return this.placesService.createPlace(createPlaceDto, req.user.uid);
  }

  @Post(':id/reviews')
  @UseGuards(FirebaseAuthGuard)
  async addReview(
    @Param('id') placeId: string,
    @Body() reviewData: any,
    @Request() req
  ) {
    const review = {
      ...reviewData,
      userId: req.user.uid,
      userName: req.user.name || req.user.email,
    };
    
    return this.placesService.addReview(placeId, review);
  }

  @Patch(':id/approve')
  @UseGuards(FirebaseAuthGuard, RolesGuard)
  @Roles('admin')
  async approvePlace(@Param('id') id: string) {
    return this.placesService.approvePlace(id);
  }

  @Patch(':id')
  @UseGuards(FirebaseAuthGuard, RolesGuard)
  @Roles('admin')
  async updatePlace(@Param('id') id: string, @Body() updateData: any) {
    return this.placesService.updatePlace(id, updateData);
  }

  @Delete(':id')
  @UseGuards(FirebaseAuthGuard, RolesGuard)
  @Roles('admin')
  async deletePlace(@Param('id') id: string) {
    await this.placesService.deletePlace(id);
    return { message: 'Place deleted successfully' };
  }
}