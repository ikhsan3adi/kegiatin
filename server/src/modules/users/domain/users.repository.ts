import { IUserProfile } from '../../auth/domain/user.types';

export interface SearchUsersParams {
  query: string;
  role?: string;
  page: number;
  limit: number;
}

export interface PaginatedUsers {
  data: IUserProfile[];
  meta: { page: number; limit: number; total: number; totalPages: number };
}

export abstract class IUsersRepository {
  abstract search(params: SearchUsersParams): Promise<PaginatedUsers>;
}
