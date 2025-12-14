import { Router } from 'express';
import { AdController, createAdValidation, editAdValidation, fetchCategoryValidation, renewAdValidation } from '../controllers/ad.controller';
import { authenticate, optionalAuth } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();
const adController = new AdController();

// Public route with optional auth
router.post('/fetch_cat', optionalAuth, validate(fetchCategoryValidation), adController.fetchCategoryAds);

// Protected routes
router.post('/create_ad', authenticate, validate(createAdValidation), adController.createAd);
router.post('/edit_ad', authenticate, validate(editAdValidation), adController.editAd);
router.post('/get_user_ads', authenticate, adController.getUserAds);
router.post('/renew', authenticate, validate(renewAdValidation), adController.renewAd);

export default router;

