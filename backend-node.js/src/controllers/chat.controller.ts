import { Request, Response, NextFunction } from 'express';
import { ChatService } from '../services/chat.service';
import { sendSuccess, sendError } from '../utils/response';
import { body, validationResult } from 'express-validator';

export class ChatController {
  private chatService: ChatService;

  constructor() {
    this.chatService = new ChatService();
  }

  getOrCreateConversation = async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }

      const conversation = await this.chatService.getOrCreateConversation(req.user.id);
      return sendSuccess(res, conversation);
    } catch (error: any) {
      next(error);
    }
  };

  getMessages = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }

      const messages = await this.chatService.getMessages(
        req.body.conversationId,
        req.user.id
      );
      return sendSuccess(res, messages);
    } catch (error: any) {
      next(error);
    }
  };

  sendMessage = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      if (!req.user) {
        return sendError(res, 'Unauthorized', 401);
      }

      const message = await this.chatService.sendMessage(
        req.body.conversationId,
        req.user.id,
        req.user.isAdmin,
        req.body.content
      );
      return sendSuccess(res, message, 'Message sent successfully');
    } catch (error: any) {
      next(error);
    }
  };

  getAdminConversations = async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.user?.isAdmin) {
        return sendError(res, 'Admin access required', 403);
      }

      const conversations = await this.chatService.getAdminConversations();
      return sendSuccess(res, conversations);
    } catch (error: any) {
      next(error);
    }
  };

  assignConversation = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, errors.array()[0].msg, 400);
      }

      if (!req.user?.isAdmin) {
        return sendError(res, 'Admin access required', 403);
      }

      const conversation = await this.chatService.assignConversation(
        req.body.conversationId,
        req.user.id
      );
      return sendSuccess(res, conversation, 'Conversation assigned successfully');
    } catch (error: any) {
      next(error);
    }
  };
}

export const getMessagesValidation = [
  body('conversationId').notEmpty().withMessage('Conversation ID is required'),
];

export const sendMessageValidation = [
  body('conversationId').notEmpty().withMessage('Conversation ID is required'),
  body('content').notEmpty().withMessage('Message content is required'),
];

export const assignConversationValidation = [
  body('conversationId').notEmpty().withMessage('Conversation ID is required'),
];

