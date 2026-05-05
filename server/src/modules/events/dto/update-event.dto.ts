import { IsEnum, IsOptional, IsString } from 'class-validator';
import { UppercaseEnum } from '../../../core/decorators/uppercase-enum.decorator';
import { EventVisibility } from '../domain/event.types';

export class UpdateEventDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @UppercaseEnum()
  @IsEnum(EventVisibility)
  visibility?: EventVisibility;

  @IsOptional()
  @IsString()
  location?: string;

  @IsOptional()
  @IsString()
  contactPerson?: string;

  @IsOptional()
  @IsString()
  imageUrl?: string;
}
