import { Inject, Injectable } from '@nestjs/common';
import { eq } from 'drizzle-orm';
import { uuidv7 } from 'uuidv7';
import { DRIZZLE } from '../../../database/drizzle.provider';
import type { DrizzleDB } from '../../../database/drizzle.provider';
import { users } from '../../../database/schema';
import { IAuthRepository } from '../domain/auth.repository';
import { ICreateUserData, IUser } from '../domain/user.types';

@Injectable()
export class DrizzleAuthRepository extends IAuthRepository {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDB) {
    super();
  }

  async findByEmail(email: string): Promise<IUser | null> {
    const rows = await this.db
      .select()
      .from(users)
      .where(eq(users.email, email.toLowerCase()))
      .limit(1);
    return rows[0] ? this.toDomain(rows[0]) : null;
  }

  async findById(id: string): Promise<IUser | null> {
    const rows = await this.db
      .select()
      .from(users)
      .where(eq(users.id, id))
      .limit(1);
    return rows[0] ? this.toDomain(rows[0]) : null;
  }

  async create(data: ICreateUserData): Promise<IUser> {
    const [row] = await this.db
      .insert(users)
      .values({
        id: uuidv7(),
        email: data.email.toLowerCase(),
        password: data.password,
        displayName: data.displayName,
        role: data.role,
        npa: data.npa ?? null,
        cabang: data.cabang ?? null,
      })
      .returning();
    return this.toDomain(row);
  }

  async updateRefreshTokenHash(
    userId: string,
    hash: string | null,
  ): Promise<void> {
    await this.db
      .update(users)
      .set({ refreshTokenHash: hash, updatedAt: new Date() })
      .where(eq(users.id, userId));
  }

  private toDomain(row: typeof users.$inferSelect): IUser {
    return {
      id: row.id,
      email: row.email,
      password: row.password,
      displayName: row.displayName,
      role: row.role as IUser['role'],
      npa: row.npa ?? null,
      cabang: row.cabang ?? null,
      photoUrl: row.photoUrl ?? null,
      emailVerified: row.emailVerified,
      refreshTokenHash: row.refreshTokenHash ?? null,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    };
  }
}
