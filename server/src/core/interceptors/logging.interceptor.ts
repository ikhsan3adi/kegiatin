import {
  CallHandler,
  ExecutionContext,
  Injectable,
  Logger,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const request: {
      method: string;
      url: string;
      body: unknown;
    } = context.switchToHttp().getRequest();
    const { method, url, body } = request;

    // Log the request details
    this.logger.log(`${method} ${url} - Body: ${JSON.stringify(body)}`);

    return next.handle();
  }
}
