import {
  Controller,
  Get,
  Param,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import { Roles } from '../../core/decorators/roles.decorator';
import { JwtAuthGuard } from '../../core/guards/jwt-auth.guard';
import { RolesGuard } from '../../core/guards/roles.guard';
import { UserRole } from '../auth/domain/user.types';
import { RequestUser } from '../auth/strategies/jwt.strategy';
import { RsvpQueryDto } from './dto/rsvp-query.dto';
import { RsvpService } from './rsvp.service';

/** Handles RSVP endpoints nested under /events/{id}/rsvp. */
@Controller('events')
@UseGuards(JwtAuthGuard, RolesGuard)
export class EventRsvpController {
  constructor(private readonly rsvpService: RsvpService) {}

  @Post(':id/rsvp')
  createRsvp(@Param('id') eventId: string, @Req() req: Request) {
    const user = req.user as RequestUser;
    return this.rsvpService.createRsvp(user.userId, eventId);
  }

  @Get(':id/rsvp')
  @Roles(UserRole.ADMIN)
  listByEvent(
    @Param('id') eventId: string,
    @Query() query: RsvpQueryDto,
  ) {
    return this.rsvpService.listByEvent(eventId, {
      page: query.page,
      limit: query.limit,
    });
  }
}
