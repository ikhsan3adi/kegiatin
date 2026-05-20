import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { Roles } from '../../core/decorators/roles.decorator';
import { JwtAuthGuard } from '../../core/guards/jwt-auth.guard';
import { RolesGuard } from '../../core/guards/roles.guard';
import { UserRole } from '../auth/domain/user.types';
import { SearchUserQueryDto } from './dto/search-user-query.dto';
import { UsersService } from './users.service';

@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('search')
  @Roles(UserRole.ADMIN)
  search(@Query() dto: SearchUserQueryDto) {
    return this.usersService.search(dto);
  }
}
