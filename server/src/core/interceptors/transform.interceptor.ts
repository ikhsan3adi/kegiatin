import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { Response } from 'express';
import { IApiResponse } from '../../shared/interfaces/api-response.interface';

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
            result.data = (data as any).data;
            result.meta = (data as any).meta;
          } else {
            result.data = data;
          }
        }

        return result;
      }),
    );
  }
}
