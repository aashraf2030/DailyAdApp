import prisma from '../config/database';
import { Request, Prisma, RequestType } from '@prisma/client';

export class RequestRepository {
  async create(data: Prisma.RequestCreateInput): Promise<Request> {
    return prisma.request.create({ data });
  }

  async findById(id: string): Promise<Request | null> {
    return prisma.request.findUnique({
      where: { id },
      include: {
        adRelation: {
          include: {
            user: {
              select: {
                username: true,
                phone: true,
              },
            },
          },
        },
        userRelation: {
          select: {
            username: true,
            phone: true,
          },
        },
      },
    });
  }

  async findByUserId(userId: string): Promise<Request[]> {
    return prisma.request.findMany({
      where: { user: userId },
      include: {
        adRelation: true,
      },
      orderBy: { creation: 'desc' },
    });
  }

  async findByType(type: RequestType): Promise<Request[]> {
    return prisma.request.findMany({
      where: { type },
      include: {
        adRelation: {
          include: {
            user: {
              select: {
                username: true,
                phone: true,
              },
            },
          },
        },
        userRelation: {
          select: {
            username: true,
            phone: true,
          },
        },
      },
      orderBy: { creation: 'desc' },
    });
  }

  async delete(id: string): Promise<void> {
    await prisma.request.delete({
      where: { id },
    });
  }
}

