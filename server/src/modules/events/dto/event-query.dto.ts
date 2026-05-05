import { Transform, Type } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, IsString, Min } from 'class-validator';
import { UppercaseEnum } from '../../../core/decorators/uppercase-enum.decorator';
import { EventStatus, EventType, EventVisibility } from '../domain/event.types';

export class EventQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit: number = 20;

  @IsOptional()
  @UppercaseEnum()
  @IsEnum(EventStatus)
  status?: EventStatus;

  @IsOptional()
  @UppercaseEnum()
  @IsEnum(EventType)
  type?: EventType;

  @IsOptional()
  @UppercaseEnum()
  @IsEnum(EventVisibility)
  visibility?: EventVisibility;

  @IsOptional()
  @IsString()
  search?: string;
}
