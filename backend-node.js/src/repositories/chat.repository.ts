import prisma from '../config/database';
import { Conversation, Message, Prisma, SenderType } from '@prisma/client';

export class ChatRepository {
  async findOrCreateConversation(userId: string): Promise<Conversation> {
    let conversation = await prisma.conversation.findFirst({
      where: {
        userId,
        isActive: true,
      },
    });

    if (!conversation) {
      conversation = await prisma.conversation.create({
        data: {
          userId,
        },
      });
    }

    return conversation;
  }

  async findConversationById(id: string): Promise<Conversation | null> {
    return prisma.conversation.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            username: true,
          },
        },
        admin: {
          select: {
            id: true,
            username: true,
          },
        },
      },
    });
  }

  async getAdminConversations(): Promise<Conversation[]> {
    return prisma.conversation.findMany({
      where: {
        isActive: true,
      },
      include: {
        user: {
          select: {
            id: true,
            username: true,
          },
        },
        admin: {
          select: {
            id: true,
            username: true,
          },
        },
        messages: {
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
      },
      orderBy: { lastMessageAt: 'desc' },
    });
  }

  async assignConversation(conversationId: string, adminId: string): Promise<Conversation> {
    return prisma.conversation.update({
      where: { id: conversationId },
      data: { adminId },
    });
  }

  async getMessages(conversationId: string, limit = 50): Promise<Message[]> {
    return prisma.message.findMany({
      where: { conversationId },
      orderBy: { createdAt: 'desc' },
      take: limit,
      include: {
        sender: {
          select: {
            id: true,
            username: true,
          },
        },
      },
    });
  }

  async createMessage(
    conversationId: string,
    senderId: string,
    senderType: SenderType,
    content: string
  ): Promise<Message> {
    const message = await prisma.message.create({
      data: {
        conversationId,
        senderId,
        senderType,
        content,
      },
      include: {
        sender: {
          select: {
            id: true,
            username: true,
          },
        },
      },
    });

    // Update conversation last message time
    await prisma.conversation.update({
      where: { id: conversationId },
      data: { lastMessageAt: new Date() },
    });

    return message;
  }
}

