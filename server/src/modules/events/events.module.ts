import { Module } from '@nestjs/common';
import { IEventRepository } from './domain/event.repository';
import { EventsController } from './events.controller';
import { EventsService } from './events.service';
import { DrizzleEventRepository } from './repositories/event.repository.impl';
import { SessionsController } from './sessions.controller';

@Module({
  controllers: [EventsController, SessionsController],
  providers: [
    { provide: IEventRepository, useClass: DrizzleEventRepository },
    EventsService,
  ],
  exports: [IEventRepository, EventsService],
})
export class EventsModule {}
