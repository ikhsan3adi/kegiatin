import { Type } from 'class-transformer';
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

  @IsEnum(EventType)
  type: EventType;

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

  @ValidateNested({ each: true })
  @Type(() => CreateSessionInlineDto)
  @ArrayMinSize(1)
  sessions: CreateSessionInlineDto[];
}
