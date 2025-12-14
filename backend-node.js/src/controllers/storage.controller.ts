import { Request, Response, NextFunction } from 'express';
import path from 'path';
import fs from 'fs';
import { sendError } from '../utils/response';
import { NotFoundError } from '../utils/errors';
import { config } from '../config/env';

export class StorageController {
  serveFile = (req: Request, res: Response, next: NextFunction) => {
    try {
      const filePath = req.params.path;
      if (!filePath) {
        throw new NotFoundError('File path not provided');
      }

      const fullPath = path.join(__dirname, '..', '..', config.upload.uploadPath, filePath);
      
      // Security: prevent directory traversal
      const resolvedPath = path.resolve(fullPath);
      const uploadsDir = path.resolve(path.join(__dirname, '..', '..', config.upload.uploadPath));
      
      if (!resolvedPath.startsWith(uploadsDir)) {
        throw new NotFoundError('File not found');
      }

      if (!fs.existsSync(resolvedPath)) {
        throw new NotFoundError('File not found');
      }

      // Set appropriate headers
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader('Content-Type', this.getContentType(resolvedPath));
      
      // Stream the file
      const fileStream = fs.createReadStream(resolvedPath);
      fileStream.pipe(res);
    } catch (error: any) {
      next(error);
    }
  };

  private getContentType(filePath: string): string {
    const ext = path.extname(filePath).toLowerCase();
    const contentTypes: { [key: string]: string } = {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.gif': 'image/gif',
      '.svg': 'image/svg+xml',
      '.pdf': 'application/pdf',
      '.txt': 'text/plain',
    };
    return contentTypes[ext] || 'application/octet-stream';
  }
}

