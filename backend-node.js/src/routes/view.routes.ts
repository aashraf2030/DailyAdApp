import { Router } from 'express';
import { ViewController, watchValidation } from '../controllers/view.controller';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();
const viewController = new ViewController();

router.post('/watch', authenticate, validate(watchValidation), viewController.watch);

export default router;

