import { ICreateUserData, IUser } from './user.types';

export abstract class IAuthRepository {
  abstract findByEmail(email: string): Promise<IUser | null>;
  abstract findById(id: string): Promise<IUser | null>;
  abstract create(data: ICreateUserData): Promise<IUser>;
  abstract updateRefreshTokenHash(
    userId: string,
    hash: string | null,
  ): Promise<void>;
}
