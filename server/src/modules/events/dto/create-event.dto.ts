import { Transform, Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsDateString,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';
import { UppercaseEnum } from '../../../core/decorators/uppercase-enum.decorator';
import { EventType, EventVisibility } from '../domain/event.types';

export class CreateSessionInlineDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsDateString()
  startTime: string;

  @IsDateString()
  endTime: string;

  @IsOptional()
  @IsString()
  location?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  capacity?: number;
}

export class CreateEventDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  @UppercaseEnum()
  @IsEnum(EventType)
  type: EventType;

  @UppercaseEnum()
  @IsEnum(EventVisibility)
  visibility: EventVisibility;

  @IsOptional()
  @IsString()
  location?: string;

  @IsOptional()
  @IsString()
  contactPerson?: string;

  @IsOptional()
  @IsString()
  imageUrl?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  maxParticipants?: number;

  @ValidateNested({ each: true })
  @Type(() => CreateSessionInlineDto)
  @ArrayMinSize(1)
  sessions: CreateSessionInlineDto[];
}
