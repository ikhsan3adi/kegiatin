import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { Response } from 'express';
import {
  IApiResponse,
  IPaginationMeta,
} from '../../shared/interfaces/api-response.interface';

@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<
  T,
  IApiResponse<T>
> {
  intercept(
    context: ExecutionContext,
    next: CallHandler<T>,
  ): Observable<IApiResponse<T>> {
    const response = context.switchToHttp().getResponse<Response>();

    return next.handle().pipe(
      map((data) => {
        const result: IApiResponse<T> = {
          success: true,
          statusCode: response.statusCode,
        };

        if (data !== undefined && data !== null) {
          // Unwrap if data already contains { data, meta } structure
          if (typeof data === 'object' && 'data' in data && 'meta' in data) {
            const wrapper = data as { data: T; meta: IPaginationMeta };
            result.data = wrapper.data;
            result.meta = wrapper.meta;
          } else {
            result.data = data;
          }
        }

        return result;
      }),
    );
  }
}
