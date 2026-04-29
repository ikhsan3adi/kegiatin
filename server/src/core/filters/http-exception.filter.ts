import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';
import { IApiErrorResponse } from '../../shared/interfaces/api-response.interface';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    let statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal server error';
    let error = 'Internal Server Error';

    if (exception instanceof HttpException) {
      statusCode = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'string') {
        message = exceptionResponse;
      } else if (typeof exceptionResponse === 'object') {
        const res = exceptionResponse as Record<string, unknown>;
        message = (res['message'] as string) ?? exception.message;
        error = (res['error'] as string) ?? error;

        if (Array.isArray(res['message'])) {
          message = (res['message'] as string[]).join(', ');
        }
      }

      error = HttpStatus[statusCode] ?? error;
    }

    const body: IApiErrorResponse = {
      success: false,
      statusCode,
      message,
      error,
    };

    if (statusCode === HttpStatus.INTERNAL_SERVER_ERROR) {
      console.error('[GlobalExceptionFilter] Unhandled Exception:', exception);
    }

    response.status(statusCode).json(body);
  }
}
