import { Inject, Injectable } from '@nestjs/common';
import { and, count, eq, ilike, or, SQL } from 'drizzle-orm';
import { DRIZZLE, DrizzleDB } from '../../../database/drizzle.provider';
import { users } from '../../../database/schema';
import { IUserProfile } from '../../auth/domain/user.types';
import { IUsersRepository, PaginatedUsers, SearchUsersParams } from '../domain/users.repository';

@Injectable()
export class DrizzleUsersRepository extends IUsersRepository {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDB) { super(); }

  async search(params: SearchUsersParams): Promise<PaginatedUsers> {
    const { query, role, page, limit } = params;
    const pattern = `%${query}%`;

    const conditions: SQL[] = [
      or(
        ilike(users.displayName, pattern),
        ilike(users.email, pattern),
        ilike(users.npa, pattern),
      )!,
    ];
    if (role) conditions.push(eq(users.role, role));

    const where = and(...conditions);

    const [{ total }] = await this.db
      .select({ total: count() })
      .from(users)
      .where(where);

    const rows = await this.db
      .select({
        id: users.id,
        email: users.email,
        displayName: users.displayName,
        role: users.role,
        npa: users.npa,
        cabang: users.cabang,
        photoUrl: users.photoUrl,
        emailVerified: users.emailVerified,
        createdAt: users.createdAt,
      })
      .from(users)
      .where(where)
      .orderBy(users.displayName)
      .limit(limit)
      .offset((page - 1) * limit);

    return {
      data: rows.map((r) => ({
        ...r,
        npa: r.npa ?? null,
        cabang: r.cabang ?? null,
        photoUrl: r.photoUrl ?? null,
      })) as IUserProfile[],
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  }
}
