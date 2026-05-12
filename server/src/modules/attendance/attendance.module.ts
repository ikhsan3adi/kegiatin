import { Module } from '@nestjs/common';
import { EventsModule } from '../events/events.module';
import { RsvpModule } from '../rsvp/rsvp.module';
import { AttendanceController } from './attendance.controller';
import { AttendanceService } from './attendance.service';
import { IAttendanceRepository } from './domain/attendance.repository';
import { DrizzleAttendanceRepository } from './repositories/attendance.repository.impl';
import { SessionsAttendanceController } from './sessions-attendance.controller';

@Module({
  imports: [EventsModule, RsvpModule],
  controllers: [AttendanceController, SessionsAttendanceController],
  providers: [
    { provide: IAttendanceRepository, useClass: DrizzleAttendanceRepository },
    AttendanceService,
  ],
  exports: [AttendanceService],
})
export class AttendanceModule {}
