import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { IAuthRepository } from './domain/auth.repository';
import {
  IAuthTokens,
  ILoginResult,
  IUser,
  IUserProfile,
  UserRole,
} from './domain/user.types';
import { RegisterDto } from './dto/register.dto';
import { JwtPayload } from './strategies/jwt.strategy';

@Injectable()
export class AuthService {
  constructor(
    private readonly authRepo: IAuthRepository,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async register(dto: RegisterDto): Promise<IUserProfile> {
    const existing = await this.authRepo.findByEmail(dto.email);
    if (existing) {
      throw new ConflictException('Email sudah terdaftar');
    }

    const hashed = await bcrypt.hash(dto.password, 10);
    const user = await this.authRepo.create({
      email: dto.email,
      password: hashed,
      displayName: dto.displayName,
      role: UserRole.MEMBER,
      npa: dto.npa,
      cabang: dto.cabang,
    });

    return this.toProfile(user);
  }

  async login(email: string, password: string): Promise<ILoginResult> {
    const user = await this.authRepo.findByEmail(email);
    if (!user) {
      throw new UnauthorizedException('Email atau password salah');
    }

    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) {
      throw new UnauthorizedException('Email atau password salah');
    }

    const tokens = await this.generateTokens(user);
    const hash = await bcrypt.hash(tokens.refreshToken, 10);
    await this.authRepo.updateRefreshTokenHash(user.id, hash);

    return { user: this.toProfile(user), tokens };
  }

  async refresh(refreshToken: string): Promise<IAuthTokens> {
    let payload: JwtPayload;
    try {
      payload = this.jwtService.verify<JwtPayload>(refreshToken, {
        secret: this.configService.getOrThrow<string>('JWT_REFRESH_SECRET'),
      });
    } catch {
      throw new UnauthorizedException(
        'Refresh token tidak valid atau kedaluwarsa',
      );
    }

    const user = await this.authRepo.findById(payload.sub);
    if (!user?.refreshTokenHash) {
      throw new UnauthorizedException('Sesi tidak ditemukan');
    }

    const isMatch = await bcrypt.compare(refreshToken, user.refreshTokenHash);
    if (!isMatch) {
      throw new UnauthorizedException('Refresh token tidak cocok');
    }

    const tokens = await this.generateTokens(user);
    const hash = await bcrypt.hash(tokens.refreshToken, 10);
    await this.authRepo.updateRefreshTokenHash(user.id, hash);

    return tokens;
  }

  async logout(userId: string): Promise<void> {
    await this.authRepo.updateRefreshTokenHash(userId, null);
  }

  async getMe(userId: string): Promise<IUserProfile> {
    const user = await this.authRepo.findById(userId);
    if (!user) throw new UnauthorizedException();
    return this.toProfile(user);
  }

  private async generateTokens(user: IUser): Promise<IAuthTokens> {
    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
    };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: this.configService.getOrThrow<string>('JWT_ACCESS_SECRET'),
        expiresIn: this.configService.get('JWT_ACCESS_EXPIRATION', '15m'),
      }),
      this.jwtService.signAsync(payload, {
        secret: this.configService.getOrThrow<string>('JWT_REFRESH_SECRET'),
        expiresIn: this.configService.get('JWT_REFRESH_EXPIRATION', '7d'),
      }),
    ]);

    return { accessToken, refreshToken };
  }

  private toProfile(user: IUser): IUserProfile {
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      role: user.role,
      npa: user.npa,
      cabang: user.cabang,
      photoUrl: user.photoUrl,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
    };
  }
}
