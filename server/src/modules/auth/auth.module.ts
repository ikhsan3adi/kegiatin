import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { IAuthRepository } from './domain/auth.repository';
import { DrizzleAuthRepository } from './repositories/auth.repository.impl';
import { JwtStrategy } from './strategies/jwt.strategy';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';

@Module({
  imports: [PassportModule, JwtModule.register({})],
  controllers: [AuthController],
  providers: [
    { provide: IAuthRepository, useClass: DrizzleAuthRepository },
    JwtStrategy,
    AuthService,
  ],
  exports: [IAuthRepository],
})
export class AuthModule {}
