import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { Roles } from '../../core/decorators/roles.decorator';
import { JwtAuthGuard } from '../../core/guards/jwt-auth.guard';
import { RolesGuard } from '../../core/guards/roles.guard';
import { UserRole } from '../auth/domain/user.types';
import { AttendanceService } from './attendance.service';
import { AttendanceListQueryDto } from './dto/attendance-list-query.dto';

@Controller('sessions')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
export class SessionsAttendanceController {
  constructor(private readonly attendanceService: AttendanceService) {}

  @Get(':id/attendance')
  listBySession(
    @Param('id') sessionId: string,
    @Query() query: AttendanceListQueryDto,
  ) {
    return this.attendanceService.listBySession(sessionId, query);
  }
}
