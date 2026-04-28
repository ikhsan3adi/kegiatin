export interface IApiResponse<T = unknown> {
  success: boolean;
  statusCode: number;
  message?: string;
  data?: T;
  meta?: IPaginationMeta;
}

export interface IApiErrorResponse {
  success: false;
  statusCode: number;
  message: string;
  error: string;
}

export interface IPaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}
