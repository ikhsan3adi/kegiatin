import { IsEnum } from 'class-validator';
import { SessionStatus } from '../domain/event.types';

export class UpdateSessionStatusDto {
  @IsEnum(SessionStatus)
  status: SessionStatus;
}
