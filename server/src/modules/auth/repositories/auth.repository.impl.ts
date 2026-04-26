import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { IAuthRepository } from '../domain/auth.repository';
import { ICreateUserData, IUser } from '../domain/user.types';
import { UserEntity } from '../entities/user.entity';

@Injectable()
export class MongooseAuthRepository extends IAuthRepository {
  constructor(
    @InjectModel(UserEntity.name) private userModel: Model<UserEntity>,
  ) {
    super();
  }

  async findByEmail(email: string): Promise<IUser | null> {
    const doc = await this.userModel
      .findOne({ email })
      .select('+password +refreshTokenHash')
      .lean<UserEntity>()
      .exec();
    return doc ? this.toDomain(doc) : null;
  }

  async findById(id: string): Promise<IUser | null> {
    const doc = await this.userModel
      .findById(id)
      .select('+refreshTokenHash')
      .lean<UserEntity>()
      .exec();
    return doc ? this.toDomain(doc) : null;
  }

  async create(data: ICreateUserData): Promise<IUser> {
    const created = await this.userModel.create(data);
    const saved = await this.userModel
      .findById(created._id)
      .lean<UserEntity>()
      .exec();
    return this.toDomain(saved!);
  }

  async updateRefreshTokenHash(
    userId: string,
    hash: string | null,
  ): Promise<void> {
    await this.userModel
      .findByIdAndUpdate(userId, { refreshTokenHash: hash })
      .exec();
  }

  private toDomain(doc: UserEntity): IUser {
    const d = doc as UserEntity & { _id: { toHexString(): string } };
    return {
      id: d._id.toHexString(),
      email: d.email,
      password: d.password ?? '',
      displayName: d.displayName,
      role: d.role,
      npa: d.npa ?? null,
      cabang: d.cabang ?? null,
      photoUrl: d.photoUrl ?? null,
      emailVerified: d.emailVerified,
      refreshTokenHash: d.refreshTokenHash ?? null,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
    };
  }
}
