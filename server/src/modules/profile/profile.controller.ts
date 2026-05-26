import {
  Body,
  Controller,
  Get,
  Patch,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import { JwtAuthGuard } from '../../core/guards/jwt-auth.guard';
import { RequestUser } from '../auth/strategies/jwt.strategy';
import { ProfileService } from './profile.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ProfileHistoryQueryDto } from './dto/profile-history-query.dto';

@Controller('profile')
@UseGuards(JwtAuthGuard)
export class ProfileController {
  constructor(private readonly profileService: ProfileService) {}

  @Get('me')
  getProfile(@Req() req: Request) {
    const user = req.user as RequestUser;
    return this.profileService.getProfile(user.userId);
  }

  @Patch('me')
  updateProfile(@Req() req: Request, @Body() dto: UpdateProfileDto) {
    const user = req.user as RequestUser;
    return this.profileService.updateProfile(user.userId, dto);
  }

  @Get('history')
  getHistory(@Req() req: Request, @Query() query: ProfileHistoryQueryDto) {
    const user = req.user as RequestUser;
    return this.profileService.getHistory(user.userId, query);
  }
}
