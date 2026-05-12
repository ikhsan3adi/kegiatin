import { Type } from 'class-transformer';
import {
  IsArray,
  IsDateString,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  ValidateNested,
} from 'class-validator';

export class SyncAttendanceRecordDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(128)
  localId!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(512)
  qrToken!: string;

  @IsUUID()
  sessionId!: string;

  @IsDateString()
  checkedInAt!: string;

  /** Client hint; server recomputes PRESENT/LATE from session start + grace. */
  @IsOptional()
  @IsString()
  status?: string;
}

export class SyncAttendanceBatchDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SyncAttendanceRecordDto)
  records!: SyncAttendanceRecordDto[];
}
