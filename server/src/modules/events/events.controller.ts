import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
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
import { CreateEventDto } from './dto/create-event.dto';
import { CreateSessionDto } from './dto/create-session.dto';
import { EventQueryDto } from './dto/event-query.dto';
import { UpdateEventDto } from './dto/update-event.dto';
import { EventsService } from './events.service';

@Controller('events')
@UseGuards(JwtAuthGuard, RolesGuard)
export class EventsController {
  constructor(private readonly eventsService: EventsService) {}

  @Get()
  findAll(@Req() req: Request, @Query() query: EventQueryDto) {
    const user = req.user as RequestUser;
    return this.eventsService.findAll(query, user.role);
  }

  @Post()
  @Roles(UserRole.ADMIN)
  create(@Req() req: Request, @Body() dto: CreateEventDto) {
    const user = req.user as RequestUser;
    return this.eventsService.create(user.userId, dto);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.eventsService.findOne(id);
  }

  @Patch(':id')
  @Roles(UserRole.ADMIN)
  update(@Param('id') id: string, @Body() dto: UpdateEventDto) {
    return this.eventsService.update(id, dto);
  }

  @Delete(':id')
  @Roles(UserRole.ADMIN)
  delete(@Param('id') id: string) {
    return this.eventsService.delete(id);
  }

  @Patch(':id/publish')
  @Roles(UserRole.ADMIN)
  publish(@Param('id') id: string) {
    return this.eventsService.publish(id);
  }

  @Patch(':id/cancel')
  @Roles(UserRole.ADMIN)
  cancel(@Param('id') id: string) {
    return this.eventsService.cancel(id);
  }

  @Patch(':id/start')
  @Roles(UserRole.ADMIN)
  start(@Param('id') id: string) {
    return this.eventsService.start(id);
  }

  @Patch(':id/complete')
  @Roles(UserRole.ADMIN)
  complete(@Param('id') id: string) {
    return this.eventsService.complete(id);
  }

  @Post(':id/sessions')
  @Roles(UserRole.ADMIN)
  addSession(@Param('id') id: string, @Body() dto: CreateSessionDto) {
    return this.eventsService.addSession(id, dto);
  }
}
