import { Router } from 'express';
import { AuthorityController, handleReqValidation, deleteReqValidation, pointsExchangeValidation } from '../controllers/authority.controller';
import { authenticate, optionalAuth } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();
const authorityController = new AuthorityController();

// Public route
router.post('/leaderboard', optionalAuth, authorityController.leaderboard);

// Protected routes
router.post('/default_req', authenticate, authorityController.defaultReq);
router.post('/renew_req', authenticate, authorityController.renewReq);
router.post('/money_req', authenticate, authorityController.moneyReq);
router.post('/my_req', authenticate, authorityController.myReq);
router.post('/handle_req', authenticate, validate(handleReqValidation), authorityController.handleReq);
router.post('/delete_req', authenticate, validate(deleteReqValidation), authorityController.deleteReq);
router.post('/points_exchange', authenticate, validate(pointsExchangeValidation), authorityController.pointsExchange);

export default router;

