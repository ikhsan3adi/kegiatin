import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';

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

  @IsEnum(UserType)
  userType: UserType;

  @IsOptional()
  @IsString()
  npa?: string;

  @IsOptional()
  @IsString()
  cabang?: string;
}
