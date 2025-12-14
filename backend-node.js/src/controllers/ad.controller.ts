import { Request, Response, NextFunction } from 'express';
import { AdService } from '../services/ad.service';
import { sendSuccess, sendError } from '../utils/response';
import { body, validationResult } from 'express-validator';
import { Category, AdType } from '@prisma/client';

export class AdController {
  private adService: AdService;

  constructor() {
    this.adService = new AdService();
  }

  createAd = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }

      const ad = await this.adService.createAd({
        name: req.body.name,
        path: req.body.path,
        image: req.body.image,
        type: req.body.type as AdType,
        category: req.body.category as Category,
        targetViews: parseInt(req.body.targetViews),
        keywords: req.body.keywords || '',
        userId: req.user.id,
      });

      return sendSuccess(res, ad, 'Ad created successfully');
    } catch (error: any) {
      next(error);
    }
  };

  editAd = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }

      const ad = await this.adService.editAd(req.body.id, req.user.id, {
        name: req.body.name,
        path: req.body.path,
        image: req.body.image,
        type: req.body.type as AdType,
        category: req.body.category as Category,
        targetViews: req.body.targetViews ? parseInt(req.body.targetViews) : undefined,
        keywords: req.body.keywords,
      });

      return sendSuccess(res, ad, 'Ad updated successfully');
    } catch (error: any) {
      next(error);
    }
  };

  getUserAds = async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }

      const ads = await this.adService.getUserAds(req.user.id);
      return sendSuccess(res, ads);
    } catch (error: any) {
      next(error);
    }
  };

  fetchCategoryAds = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      const ads = await this.adService.fetchCategoryAds(
        req.body.category as Category,
        req.user?.id
      );
      return sendSuccess(res, ads);
    } catch (error: any) {
      next(error);
    }
  };

  renewAd = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }

      const result = await this.adService.renewAd(req.body.id, req.user.id);
      return sendSuccess(res, result, 'Renewal request created');
    } catch (error: any) {
      next(error);
    }
  };
}

export const createAdValidation = [
  body('name').notEmpty().withMessage('Ad name is required'),
  body('path').notEmpty().withMessage('Ad path is required'),
  body('image').notEmpty().withMessage('Ad image is required'),
  body('type').isIn(['Fixed', 'Dynamic']).withMessage('Invalid ad type'),
  body('category').isIn([
    'Electronics',
    'Fashion',
    'Health',
    'Home',
    'Groceries',
    'Games',
    'Books',
    'Automotive',
    'Pet',
    'Food',
    'Other',
  ]).withMessage('Invalid category'),
  body('targetViews').isInt({ min: 1 }).withMessage('Target views must be a positive integer'),
];

export const editAdValidation = [
  body('id').notEmpty().withMessage('Ad ID is required'),
];

export const fetchCategoryValidation = [
  body('category').isIn([
    'Electronics',
    'Fashion',
    'Health',
    'Home',
    'Groceries',
    'Games',
    'Books',
    'Automotive',
    'Pet',
    'Food',
    'Other',
  ]).withMessage('Invalid category'),
];

export const renewAdValidation = [
  body('id').notEmpty().withMessage('Ad ID is required'),
];

