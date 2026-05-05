import {
  ValidationPipe,
  VERSION_NEUTRAL,
  VersioningType,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory, Reflector } from '@nestjs/core';
import * as morgan from 'morgan';
import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './core/filters/http-exception.filter';
import { TransformInterceptor } from './core/interceptors/transform.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.use(morgan.default('combined'));

  app.useGlobalFilters(new GlobalExceptionFilter());

  app.useGlobalInterceptors(new TransformInterceptor());

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  const reflector = app.get(Reflector);

  app.setGlobalPrefix('api');

  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: VERSION_NEUTRAL,
  });

  app.enableCors();

  const config = app.get(ConfigService);
  const port = config.get<number>('PORT', 3000);
  await app.listen(port);
}
bootstrap();
