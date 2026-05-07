import {
  Controller,
  Delete,
  Get,
  Param,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import { JwtAuthGuard } from '../../core/guards/jwt-auth.guard';
import { RolesGuard } from '../../core/guards/roles.guard';
import { RequestUser } from '../auth/strategies/jwt.strategy';
import { RsvpQueryDto } from './dto/rsvp-query.dto';
import { RsvpService } from './rsvp.service';

/** Handles standalone RSVP endpoints under /rsvp/*. */
@Controller('rsvp')
@UseGuards(JwtAuthGuard, RolesGuard)
export class RsvpController {
  constructor(private readonly rsvpService: RsvpService) {}

  /** Must be declared before :id routes to avoid NestJS treating "me" as an id param. */
  @Get('me')
  listMyRsvps(@Req() req: Request, @Query() query: RsvpQueryDto) {
    const user = req.user as RequestUser;
    return this.rsvpService.listMyRsvps(user.userId, {
      page: query.page,
      limit: query.limit,
    });
  }

  @Get(':id/qr')
  getQrToken(@Param('id') rsvpId: string, @Req() req: Request) {
    const user = req.user as RequestUser;
    return this.rsvpService.getQrToken(rsvpId, user.userId);
  }

  @Delete(':id')
  cancelRsvp(@Param('id') rsvpId: string, @Req() req: Request) {
    const user = req.user as RequestUser;
    return this.rsvpService.cancelRsvp(rsvpId, user.userId);
  }
}
