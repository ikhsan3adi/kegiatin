import { IsEnum } from 'class-validator';
import { UppercaseEnum } from '../../../core/decorators/uppercase-enum.decorator';
import { SessionStatus } from '../domain/event.types';

export class UpdateSessionStatusDto {
  @UppercaseEnum()
  @IsEnum(SessionStatus)
  status: SessionStatus;
}
