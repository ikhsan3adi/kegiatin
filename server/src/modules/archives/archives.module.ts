import { Module } from '@nestjs/common';
import { ArchivesController } from './archives.controller';
import { ArchivesService } from './archives.service';
import { IArchiveRepository } from './repositories/archive.repository';
import { DrizzleArchiveRepository } from './repositories/archive.repository.impl';

@Module({
  controllers: [ArchivesController],
  providers: [
    { provide: IArchiveRepository, useClass: DrizzleArchiveRepository },
    ArchivesService,
  ],
})
export class ArchivesModule {}
