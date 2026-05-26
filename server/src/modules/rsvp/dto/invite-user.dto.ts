import { IsNotEmpty, IsUUID } from 'class-validator';

export class InviteUserDto {
  @IsUUID(4, { message: 'userId harus berupa UUID v4 yang valid' })
  @IsNotEmpty({ message: 'userId tidak boleh kosong' })
  userId!: string;
}
