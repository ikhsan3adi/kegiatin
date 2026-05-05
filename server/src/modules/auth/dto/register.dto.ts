import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';
import { UppercaseEnum } from '../../../core/decorators/uppercase-enum.decorator';

export enum UserType {
  ANGGOTA = 'ANGGOTA',
  UMUM = 'UMUM',
}

export class RegisterDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;

  @IsString()
  @IsNotEmpty()
  displayName: string;

  @UppercaseEnum()
  @IsEnum(UserType)
  userType: UserType;

  @IsOptional()
  @IsString()
  npa?: string;

  @IsOptional()
  @IsString()
  cabang?: string;
}
