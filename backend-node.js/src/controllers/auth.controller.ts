import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/auth.service';
import { sendSuccess, sendError } from '../utils/response';
import { extractTokenFromHeader } from '../utils/jwt';
import { body, validationResult } from 'express-validator';

export class AuthController {
  private authService: AuthService;

  constructor() {
    this.authService = new AuthService();
  }

  register = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      const result = await this.authService.register(req.body);
      return sendSuccess(res, result, 'Registration successful');
    } catch (error: any) {
      next(error);
    }
  };

  login = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      const result = await this.authService.login(req.body.username, req.body.password);
      return sendSuccess(res, result, 'Login successful');
    } catch (error: any) {
      next(error);
    }
  };

  logout = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const token = extractTokenFromHeader(req.headers.authorization);
      if (token) {
        await this.authService.logout(token);
      }
      return sendSuccess(res, null, 'Logout successful');
    } catch (error: any) {
      next(error);
    }
  };

  profile = async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }
      const profile = await this.authService.getProfile(req.user.id);
      return sendSuccess(res, profile);
    } catch (error: any) {
      next(error);
    }
  };

  isLoggedIn = async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.user) {
        return sendSuccess(res, { loggedIn: false });
      }
      return sendSuccess(res, { loggedIn: true, user: req.user });
    } catch (error: any) {
      next(error);
    }
  };

  isAdmin = async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.user) {
        return sendSuccess(res, { isAdmin: false });
      }
      return sendSuccess(res, { isAdmin: req.user.isAdmin });
    } catch (error: any) {
      next(error);
    }
  };

  delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }
      await this.authService.deleteUser(req.user.id);
      return sendSuccess(res, null, 'User deleted successfully');
    } catch (error: any) {
      next(error);
    }
  };

  sendCode = async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }
      const result = await this.authService.sendVerificationCode(req.user.id);
      return sendSuccess(res, result, 'Verification code sent');
    } catch (error: any) {
      next(error);
    }
  };

  verify = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }
      const result = await this.authService.verifyEmail(req.user.id, req.body.code);
      return sendSuccess(res, result, 'Email verified');
    } catch (error: any) {
      next(error);
    }
  };

  isVerified = async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.user) {
        return sendSuccess(res, { isVerified: false });
      }
      const profile = await this.authService.getProfile(req.user.id);
      return sendSuccess(res, { isVerified: profile.isVerified });
    } catch (error: any) {
      next(error);
    }
  };

  passReset = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      const result = await this.authService.resetPassword(req.body.email);
      return sendSuccess(res, result, 'Reset code sent');
    } catch (error: any) {
      next(error);
    }
  };

  validateReset = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      const result = await this.authService.validateResetCode(
        req.body.email,
        req.body.code
      );
      return sendSuccess(res, result, 'Reset code validated');
    } catch (error: any) {
      next(error);
    }
  };

  changePass = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }
      await this.authService.changePassword(
        req.user.id,
        req.body.oldPassword,
        req.body.newPassword
      );
      return sendSuccess(res, null, 'Password changed successfully');
    } catch (error: any) {
      next(error);
    }
  };
}

export const registerValidation = [
  body('fullname').notEmpty().withMessage('Fullname is required'),
  body('username').notEmpty().withMessage('Username is required'),
  body('email').isEmail().withMessage('Valid email is required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
];

export const loginValidation = [
  body('username').notEmpty().withMessage('Username is required'),
  body('password').notEmpty().withMessage('Password is required'),
];

export const verifyValidation = [
  body('code').notEmpty().withMessage('Verification code is required'),
];

export const resetPasswordValidation = [
  body('email').isEmail().withMessage('Valid email is required'),
];

export const validateResetValidation = [
  body('email').isEmail().withMessage('Valid email is required'),
  body('code').notEmpty().withMessage('Reset code is required'),
];

export const changePasswordValidation = [
  body('oldPassword').notEmpty().withMessage('Old password is required'),
  body('newPassword').isLength({ min: 6 }).withMessage('New password must be at least 6 characters'),
];

