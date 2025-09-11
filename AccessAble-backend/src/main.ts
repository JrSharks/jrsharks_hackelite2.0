import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as cors from 'cors';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  // Security middleware
  app.use(helmet());
  
  // CORS configuration
  const nodeEnv = process.env.NODE_ENV || 'development';
  const allowOriginsEnv = process.env.ALLOW_CORS_ORIGINS || '';
  const explicitAllowedOrigins = allowOriginsEnv
    .split(',')
    .map((o) => o.trim())
    .filter((o) => o.length > 0);

  app.use(cors({
    origin: (origin, callback) => {
      // Allow non-browser requests (e.g., curl, server-to-server)
      if (!origin) return callback(null, true);

      // Always allow explicitly configured origins
      if (explicitAllowedOrigins.includes(origin)) return callback(null, true);

      // In development, allow any localhost origin (covers Flutter Web random ports and Vite)
      if (nodeEnv !== 'production' && /^http:\/\/localhost:\d+$/.test(origin)) {
        return callback(null, true);
      }

      // Block everything else by default
      return callback(new Error('Not allowed by CORS'), false);
    },
    credentials: true,
    methods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  }));

  // Global validation pipe
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  // API prefix
  app.setGlobalPrefix('api/v1');

  const port = configService.get('PORT') || 3001;
  await app.listen(port);
  
  console.log(`🚀 AccessAble Backend is running on: http://localhost:${port}/api/v1`);
}

bootstrap();