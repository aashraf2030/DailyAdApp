import { Router } from 'express';
import { AuthController, registerValidation, loginValidation, verifyValidation, resetPasswordValidation, validateResetValidation, changePasswordValidation } from '../controllers/auth.controller';
import { authenticate, optionalAuth } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();
const authController = new AuthController();

// Public routes
router.post('/register', validate(registerValidation), authController.register);
router.post('/login', validate(loginValidation), authController.login);
router.post('/pass_reset', validate(resetPasswordValidation), authController.passReset);

// Protected routes
router.post('/logout', authenticate, authController.logout);
router.post('/profile', authenticate, authController.profile);
router.post('/is_logged_in', authenticate, authController.isLoggedIn);
router.post('/is_admin', authenticate, authController.isAdmin);
router.post('/delete', authenticate, authController.delete);
router.post('/send_code', authenticate, authController.sendCode);
router.post('/verify', authenticate, validate(verifyValidation), authController.verify);
router.post('/is_verified', authenticate, authController.isVerified);
router.post('/validate_reset', validate(validateResetValidation), authController.validateReset);
router.post('/change_pass', authenticate, validate(changePasswordValidation), authController.changePass);

export default router;

