import { Module } from '@nestjs/common';
import { EventsModule } from '../events/events.module';
import { IRsvpRepository } from './domain/rsvp.repository';
import { EventRsvpController } from './event-rsvp.controller';
import { DrizzleRsvpRepository } from './repositories/rsvp.repository.impl';
import { RsvpController } from './rsvp.controller';
import { RsvpService } from './rsvp.service';

@Module({
  imports: [EventsModule],
  controllers: [EventRsvpController, RsvpController],
  providers: [
    { provide: IRsvpRepository, useClass: DrizzleRsvpRepository },
    RsvpService,
  ],
  exports: [IRsvpRepository, RsvpService],
})
export class RsvpModule {}
