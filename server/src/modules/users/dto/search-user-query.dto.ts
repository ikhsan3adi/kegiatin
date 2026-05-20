import { IsOptional, IsString, MinLength, IsInt, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

export class SearchUserQueryDto {
  @IsString()
  @MinLength(2)
  q: string;

  @IsOptional()
  @IsString()
  role?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number = 20;
}
