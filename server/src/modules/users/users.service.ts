import { Injectable } from '@nestjs/common';
import { IUsersRepository } from './domain/users.repository';
import { SearchUserQueryDto } from './dto/search-user-query.dto';

@Injectable()
export class UsersService {
  constructor(private readonly usersRepository: IUsersRepository) {}

  async search(dto: SearchUserQueryDto) {
    return this.usersRepository.search({
      query: dto.q,
      role: dto.role,
      page: dto.page ?? 1,
      limit: dto.limit ?? 20,
    });
  }
}
