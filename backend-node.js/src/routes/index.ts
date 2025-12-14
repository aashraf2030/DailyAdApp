import { Router } from 'express';
import authRoutes from './auth.routes';
import adRoutes from './ad.routes';
import viewRoutes from './view.routes';
import authorityRoutes from './authority.routes';
import chatRoutes from './chat.routes';
import { StorageController } from '../controllers/storage.controller';

const router = Router();
const storageController = new StorageController();

// Test route
router.get('/test', (req, res) => {
  res.json({
    status: 'Success',
    message: 'API is working!',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// Storage route (for serving files with CORS)
router.get('/storage/:path(*)', storageController.serveFile);

// API routes
router.use('/auth', authRoutes);
router.use('/ad', adRoutes);
router.use('/view', viewRoutes);
router.use('/authority', authorityRoutes);
router.use('/chat', chatRoutes);

export default router;

