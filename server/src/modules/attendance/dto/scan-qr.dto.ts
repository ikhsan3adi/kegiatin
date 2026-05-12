import { IsNotEmpty, IsString, IsUUID, MaxLength } from 'class-validator';

export class ScanQrDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(512)
  qrToken!: string;

  @IsUUID()
  sessionId!: string;
}
