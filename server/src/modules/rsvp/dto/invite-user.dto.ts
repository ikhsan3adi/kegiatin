import { IsNotEmpty, IsUUID } from 'class-validator';

export class InviteUserDto {
  @IsUUID('all', { message: 'userId harus berupa UUID yang valid' })
  @IsNotEmpty({ message: 'userId tidak boleh kosong' })
  userId!: string;
}
