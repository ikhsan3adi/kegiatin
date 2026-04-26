import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { MongooseModule } from '@nestjs/mongoose';
import { PassportModule } from '@nestjs/passport';
import { UserEntity, UserSchema } from './entities/user.entity';
import { IAuthRepository } from './domain/auth.repository';
import { MongooseAuthRepository } from './repositories/auth.repository.impl';
import { JwtStrategy } from './strategies/jwt.strategy';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: UserEntity.name, schema: UserSchema }]),
    PassportModule,
    JwtModule.register({}),
  ],
  controllers: [AuthController],
  providers: [
    { provide: IAuthRepository, useClass: MongooseAuthRepository },
    JwtStrategy,
    AuthService,
  ],
  exports: [IAuthRepository],
})
export class AuthModule {}
