import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { IEventRepository } from './domain/event.repository';
import { EventEntity, EventSchema } from './entities/event.entity';
import { SessionEntity, SessionSchema } from './entities/session.entity';
import { EventsController } from './events.controller';
import { EventsService } from './events.service';
import { MongooseEventRepository } from './repositories/event.repository.impl';
import { SessionsController } from './sessions.controller';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: EventEntity.name, schema: EventSchema },
      { name: SessionEntity.name, schema: SessionSchema },
    ]),
  ],
  controllers: [EventsController, SessionsController],
  providers: [
    { provide: IEventRepository, useClass: MongooseEventRepository },
    EventsService,
  ],
  exports: [IEventRepository, EventsService],
})
export class EventsModule {}
