import { ChatRepository } from '../repositories/chat.repository';
import { NotFoundError, ForbiddenError } from '../utils/errors';
import { SenderType } from '@prisma/client';

export class ChatService {
  private chatRepository: ChatRepository;

  constructor() {
    this.chatRepository = new ChatRepository();
  }

  async getOrCreateConversation(userId: string) {
    const conversation = await this.chatRepository.findOrCreateConversation(userId);
    return {
      id: conversation.id,
      userId: conversation.userId,
      adminId: conversation.adminId,
      subject: conversation.subject,
      isActive: conversation.isActive,
      lastMessageAt: conversation.lastMessageAt,
      unreadCountUser: conversation.unreadCountUser,
      unreadCountAdmin: conversation.unreadCountAdmin,
    };
  }

  async getMessages(conversationId: string, userId: string) {
    const conversation = await this.chatRepository.findConversationById(conversationId);
    if (!conversation) {
      throw new NotFoundError('Conversation not found');
    }

    if (conversation.userId !== userId && conversation.adminId !== userId) {
      throw new ForbiddenError('Not authorized to view this conversation');
    }

    const messages = await this.chatRepository.getMessages(conversationId);
    return messages.reverse().map(msg => ({
      id: msg.id,
      conversationId: msg.conversationId,
      senderId: msg.senderId,
      senderType: msg.senderType,
      content: msg.content,
      isRead: msg.isRead,
      readAt: msg.readAt,
      createdAt: msg.createdAt,
      sender: msg.sender,
    }));
  }

  async sendMessage(
    conversationId: string,
    senderId: string,
    isAdmin: boolean,
    content: string
  ) {
    const conversation = await this.chatRepository.findConversationById(conversationId);
    if (!conversation) {
      throw new NotFoundError('Conversation not found');
    }

    if (conversation.userId !== senderId && conversation.adminId !== senderId) {
      throw new ForbiddenError('Not authorized to send message in this conversation');
    }

    const message = await this.chatRepository.createMessage(
      conversationId,
      senderId,
      isAdmin ? SenderType.admin : SenderType.user,
      content
    );

    return {
      id: message.id,
      conversationId: message.conversationId,
      senderId: message.senderId,
      senderType: message.senderType,
      content: message.content,
      isRead: message.isRead,
      createdAt: message.createdAt,
      sender: message.sender,
    };
  }

  async getAdminConversations() {
    const conversations = await this.chatRepository.getAdminConversations();
    return conversations.map(conv => ({
      id: conv.id,
      userId: conv.userId,
      adminId: conv.adminId,
      subject: conv.subject,
      isActive: conv.isActive,
      lastMessageAt: conv.lastMessageAt,
      unreadCountUser: conv.unreadCountUser,
      unreadCountAdmin: conv.unreadCountAdmin,
      user: conv.user,
      admin: conv.admin,
      lastMessage: conv.messages[0] || null,
    }));
  }

  async assignConversation(conversationId: string, adminId: string) {
    const conversation = await this.chatRepository.findConversationById(conversationId);
    if (!conversation) {
      throw new NotFoundError('Conversation not found');
    }

    const updated = await this.chatRepository.assignConversation(conversationId, adminId);
    return {
      id: updated.id,
      userId: updated.userId,
      adminId: updated.adminId,
    };
  }
}

