import { Injectable, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { existsSync, mkdirSync, writeFileSync } from 'fs';
import { extname, join } from 'path';
import { uuidv7 } from 'uuidv7';

@Injectable()
export class UploadsService {
  private readonly uploadDir: string;
  private readonly baseUrl: string;

  constructor(private readonly config: ConfigService) {
    this.uploadDir = join(process.cwd(), 'public', 'uploads');
    if (!existsSync(this.uploadDir)) {
      mkdirSync(this.uploadDir, { recursive: true });
    }
    const envBaseUrl = config.get<string>('BASE_URL');
    if (envBaseUrl) {
      this.baseUrl = `${envBaseUrl.replace(/\/$/, '')}/uploads`;
    } else {
      this.baseUrl = `http://localhost:${config.get<number>('PORT', 3000)}/uploads`;
    }
  }

  saveImage(file: Express.Multer.File): { url: string } {
    const allowedMimes = [
      'image/jpeg',
      'image/png',
      'image/webp',
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'text/plain',
      'application/zip',
      'application/x-zip-compressed',
    ];
    if (!allowedMimes.includes(file.mimetype)) {
      throw new BadRequestException(
        'Format file tidak didukung.',
      );
    }

    const maxSize = 5 * 1024 * 1024; // 5MB
    if (file.size > maxSize) {
      throw new BadRequestException('Ukuran file maksimal 5MB.');
    }

    const ext = extname(file.originalname).toLowerCase() || '.jpg';
    const filename = `${uuidv7()}${ext}`;
    const filepath = join(this.uploadDir, filename);

    writeFileSync(filepath, file.buffer);

    return { url: `${this.baseUrl}/${filename}` };
  }
}
