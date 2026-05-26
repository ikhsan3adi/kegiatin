import { IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  @MaxLength(255)
  displayName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  cabang?: string;

  @IsOptional()
  @IsString()
  @MaxLength(512)
  photoUrl?: string;
}
