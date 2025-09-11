import { Controller, Get, UseGuards, Request, Patch, Body } from '@nestjs/common';
import { AuthService } from './auth.service';
import { FirebaseAuthGuard } from './guards/firebase-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Get('profile')
  @UseGuards(FirebaseAuthGuard)
  async getProfile(@Request() req) {
    return this.authService.getUserProfile(req.user.uid);
  }

  @Patch('profile')
  @UseGuards(FirebaseAuthGuard)
  async updateProfile(@Request() req, @Body() updateData: any) {
    return this.authService.updateUserProfile(req.user.uid, updateData);
  }

  @Get('verify')
  @UseGuards(FirebaseAuthGuard)
  async verifyToken(@Request() req) {
    return {
      uid: req.user.uid,
      email: req.user.email,
      verified: true,
      message: 'Token is valid'
    };
  }
}