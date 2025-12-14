import { Request, Response, NextFunction } from 'express';
import { AuthorityService } from '../services/authority.service';
import { UserRepository } from '../repositories/user.repository';
import { sendSuccess, sendError } from '../utils/response';
import { body, validationResult } from 'express-validator';

export class AuthorityController {
  private authorityService: AuthorityService;
  private userRepository: UserRepository;

  constructor() {
    this.authorityService = new AuthorityService();
    this.userRepository = new UserRepository();
  }

  defaultReq = async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.user?.isAdmin) {
        return sendError(res, 'Admin access required', 403);
      }
      const requests = await this.authorityService.getDefaultRequests();
      return sendSuccess(res, requests);
    } catch (error: any) {
      next(error);
    }
  };

  renewReq = async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.user?.isAdmin) {
        return sendError(res, 'Admin access required', 403);
      }
      const requests = await this.authorityService.getRenewRequests();
      return sendSuccess(res, requests);
    } catch (error: any) {
      next(error);
    }
  };

  moneyReq = async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.user?.isAdmin) {
        return sendError(res, 'Admin access required', 403);
      }
      const requests = await this.authorityService.getMoneyRequests();
      return sendSuccess(res, requests);
    } catch (error: any) {
      next(error);
    }
  };

  myReq = async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }
      const requests = await this.authorityService.getMyRequests(req.user.id);
      return sendSuccess(res, requests);
    } catch (error: any) {
      next(error);
    }
  };

  handleReq = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      if (!req.user?.isAdmin) {
        return sendError(res, 'Admin access required', 403);
      }

      const result = await this.authorityService.handleRequest(
        req.body.id,
        req.body.approved,
        req.user.id
      );
      return sendSuccess(res, result, 'Request handled successfully');
    } catch (error: any) {
      next(error);
    }
  };

  deleteReq = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }

      await this.authorityService.deleteRequest(req.body.id, req.user.id);
      return sendSuccess(res, null, 'Request deleted successfully');
    } catch (error: any) {
      next(error);
    }
  };

  leaderboard = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const limit = parseInt(req.body.limit || '10');
      const currentUserId = req.user?.id;
      const leaderboard = await this.userRepository.getLeaderboard(
        limit,
        currentUserId
      );
      return sendSuccess(res, leaderboard);
    } catch (error: any) {
      next(error);
    }
  };

  pointsExchange = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }

      const result = await this.authorityService.pointsExchange(
        req.user.id,
        parseFloat(req.body.points)
      );
      return sendSuccess(res, result, 'Exchange request created');
    } catch (error: any) {
      next(error);
    }
  };
}

export const handleReqValidation = [
  body('id').notEmpty().withMessage('Request ID is required'),
  body('approved').isBoolean().withMessage('Approved must be a boolean'),
];

export const deleteReqValidation = [
  body('id').notEmpty().withMessage('Request ID is required'),
];

export const pointsExchangeValidation = [
  body('points').isFloat({ min: 0.01 }).withMessage('Points must be a positive number'),
];

