import prisma from '../config/database';
import { Ad, Prisma, Category, AdType } from '@prisma/client';

export class AdRepository {
  async create(data: Prisma.AdCreateInput): Promise<Ad> {
    return prisma.ad.create({ data });
  }

  async findById(id: string): Promise<Ad | null> {
    return prisma.ad.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            phone: true,
          },
        },
      },
    });
  }

  async findByUserId(userId: string): Promise<Ad[]> {
    return prisma.ad.findMany({
      where: { userid: userId },
      orderBy: { creationDate: 'desc' },
    });
  }

  async findByCategory(
    category: Category,
    excludeUserId?: string
  ): Promise<Ad[]> {
    return prisma.ad.findMany({
      where: {
        category,
        isPublished: true,
        ...(excludeUserId && { userid: { not: excludeUserId } }),
      },
      orderBy: { creationDate: 'desc' },
      include: {
        user: {
          select: {
            id: true,
            username: true,
          },
        },
      },
    });
  }

  async update(id: string, data: Prisma.AdUpdateInput): Promise<Ad> {
    return prisma.ad.update({
      where: { id },
      data,
    });
  }

  async incrementViews(id: string): Promise<Ad> {
    return prisma.ad.update({
      where: { id },
      data: {
        views: {
          increment: 1,
        },
      },
    });
  }

  async delete(id: string): Promise<void> {
    await prisma.ad.delete({
      where: { id },
    });
  }
}

