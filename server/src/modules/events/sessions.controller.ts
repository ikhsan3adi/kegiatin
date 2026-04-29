import {
  Body,
  Controller,
  Delete,
  Param,
  Patch,
  UseGuards,
} from '@nestjs/common';
import { Roles } from '../../core/decorators/roles.decorator';
import { JwtAuthGuard } from '../../core/guards/jwt-auth.guard';
import { RolesGuard } from '../../core/guards/roles.guard';
import { UserRole } from '../auth/domain/user.types';
import { UpdateSessionStatusDto } from './dto/update-session-status.dto';
import { UpdateSessionDto } from './dto/update-session.dto';
import { EventsService } from './events.service';

@Controller('sessions')
@UseGuards(JwtAuthGuard, RolesGuard)
export class SessionsController {
  constructor(private readonly eventsService: EventsService) {}

  @Patch(':id')
  @Roles(UserRole.ADMIN)
  updateSession(@Param('id') id: string, @Body() dto: UpdateSessionDto) {
    return this.eventsService.updateSession(id, dto);
  }

  @Delete(':id')
  @Roles(UserRole.ADMIN)
  deleteSession(@Param('id') id: string) {
    return this.eventsService.deleteSession(id);
  }

  @Patch(':id/status')
  @Roles(UserRole.ADMIN)
  updateSessionStatus(
    @Param('id') id: string,
    @Body() dto: UpdateSessionStatusDto,
  ) {
    return this.eventsService.updateSessionStatus(id, dto);
  }
}
