export enum UserRole {
  ADMIN = 'ADMIN',
  MEMBER = 'MEMBER',
}

export interface IUser {
  id: string;
  email: string;
  password: string;
  displayName: string;
  role: UserRole;
  npa: string | null;
  cabang: string | null;
  photoUrl: string | null;
  emailVerified: boolean;
  refreshTokenHash: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface IUserProfile {
  id: string;
  email: string;
  displayName: string;
  role: UserRole;
  npa: string | null;
  cabang: string | null;
  photoUrl: string | null;
  emailVerified: boolean;
  createdAt: Date;
}

export interface IAuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface ILoginResult {
  user: IUserProfile;
  tokens: IAuthTokens;
}

export interface ICreateUserData {
  email: string;
  password: string;
  displayName: string;
  role: UserRole;
  npa?: string;
  cabang?: string;
}
