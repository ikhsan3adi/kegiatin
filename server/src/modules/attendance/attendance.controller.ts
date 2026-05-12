import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { Roles } from '../../core/decorators/roles.decorator';
import { JwtAuthGuard } from '../../core/guards/jwt-auth.guard';
import { RolesGuard } from '../../core/guards/roles.guard';
import { UserRole } from '../auth/domain/user.types';
import { AttendanceService } from './attendance.service';
import { AttendanceLookupQueryDto } from './dto/attendance-lookup-query.dto';
import { ScanQrDto } from './dto/scan-qr.dto';
import { SyncAttendanceBatchDto } from './dto/sync-attendance.dto';

@Controller('attendance')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
export class AttendanceController {
  constructor(private readonly attendanceService: AttendanceService) {}

  @Post('scan')
  @HttpCode(HttpStatus.CREATED)
  scan(@Body() dto: ScanQrDto) {
    return this.attendanceService.scan(dto);
  }

  @Post('sync')
  @HttpCode(HttpStatus.OK)
  sync(@Body() dto: SyncAttendanceBatchDto) {
    return this.attendanceService.sync(dto);
  }

  @Get('lookup')
  lookup(@Query() query: AttendanceLookupQueryDto) {
    return this.attendanceService.lookup(query.qrToken, query.sessionId);
  }
}
