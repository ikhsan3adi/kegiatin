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
    this.baseUrl = `http://localhost:${config.get<number>('PORT', 3000)}/uploads`;
  }

  saveImage(file: Express.Multer.File): { url: string } {
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    if (!allowedMimes.includes(file.mimetype)) {
      throw new BadRequestException(
        'Format file tidak didukung. Gunakan JPEG, PNG, atau WEBP.',
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
