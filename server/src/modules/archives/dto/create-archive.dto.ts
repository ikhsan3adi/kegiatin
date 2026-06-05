import { IsEnum, IsString, IsUrl, MaxLength } from 'class-validator';
import { ArchiveType } from '../domain/archive.types';

export class CreateArchiveDto {
  @IsString()
  @MaxLength(500)
  title: string;

  @IsEnum(ArchiveType)
  type: ArchiveType;

  @IsString()
  @MaxLength(1024)
  fileUrl: string;
}
