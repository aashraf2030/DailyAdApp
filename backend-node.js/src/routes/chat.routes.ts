import { Router } from 'express';
import { ChatController, getMessagesValidation, sendMessageValidation, assignConversationValidation } from '../controllers/chat.controller';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();
const chatController = new ChatController();

// User routes
router.post('/conversation', authenticate, chatController.getOrCreateConversation);
router.post('/messages', authenticate, validate(getMessagesValidation), chatController.getMessages);
router.post('/send', authenticate, validate(sendMessageValidation), chatController.sendMessage);

// Admin routes
router.get('/admin/conversations', authenticate, chatController.getAdminConversations);
router.post('/admin/assign', authenticate, validate(assignConversationValidation), chatController.assignConversation);

export default router;

