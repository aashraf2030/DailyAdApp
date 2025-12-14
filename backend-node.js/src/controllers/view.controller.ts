import { Request, Response, NextFunction } from 'express';
import { ViewService } from '../services/view.service';
import { sendSuccess, sendError } from '../utils/response';
import { body, validationResult } from 'express-validator';

export class ViewController {
  private viewService: ViewService;

  constructor() {
    this.viewService = new ViewService();
  }

  watch = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }

      const result = await this.viewService.watchAd(req.body.id, req.user.id);
      return sendSuccess(res, result, 'Ad viewed successfully');
    } catch (error: any) {
      next(error);
    }
  };
}

export const watchValidation = [
  body('id').notEmpty().withMessage('Ad ID is required'),
];

