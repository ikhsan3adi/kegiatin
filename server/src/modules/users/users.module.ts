import { Module } from '@nestjs/common';
import { IUsersRepository } from './domain/users.repository';
import { DrizzleUsersRepository } from './repositories/users.repository.impl';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';

@Module({
  controllers: [UsersController],
  providers: [
    { provide: IUsersRepository, useClass: DrizzleUsersRepository },
    UsersService,
  ],
})
export class UsersModule {}
