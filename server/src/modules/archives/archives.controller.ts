import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import { Roles } from '../../core/decorators/roles.decorator';
import { JwtAuthGuard } from '../../core/guards/jwt-auth.guard';
import { RolesGuard } from '../../core/guards/roles.guard';
import { UserRole } from '../auth/domain/user.types';
import { RequestUser } from '../auth/strategies/jwt.strategy';
import { ArchivesService } from './archives.service';
import { CreateArchiveDto } from './dto/create-archive.dto';

@Controller()
@UseGuards(JwtAuthGuard, RolesGuard)
export class ArchivesController {
  constructor(private readonly archivesService: ArchivesService) {}

  @Get('sessions/:id/archives')
  findBySessionId(@Param('id') id: string, @Req() req: Request) {
    const user = req.user as RequestUser;
    return this.archivesService.findBySessionId(id, user.userId, user.role);
  }

  @Post('sessions/:id/archives')
  @Roles(UserRole.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  create(@Param('id') id: string, @Body() dto: CreateArchiveDto) {
    return this.archivesService.create(id, dto);
  }

  @Delete('archives/:id')
  @Roles(UserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  delete(@Param('id') id: string) {
    return this.archivesService.delete(id);
  }
}
