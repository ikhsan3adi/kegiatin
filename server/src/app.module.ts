import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { DrizzleModule } from './database/drizzle.module';
import { AuthModule } from './modules/auth/auth.module';
import { EventsModule } from './modules/events/events.module';
import { RsvpModule } from './modules/rsvp/rsvp.module';
import { AttendanceModule } from './modules/attendance/attendance.module';
import { UsersModule } from './modules/users/users.module';
import { ProfileModule } from './modules/profile/profile.module';
import { UploadsModule } from './modules/uploads/uploads.module';
import { ArchivesModule } from './modules/archives/archives.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    DrizzleModule,
    AuthModule,
    EventsModule,
    RsvpModule,
    AttendanceModule,
    UsersModule,
    ProfileModule,
    UploadsModule,
    ArchivesModule,
  ],
})
export class AppModule {}
