import prisma from '../config/database';
import { View, Prisma } from '@prisma/client';

export class ViewRepository {
  async create(data: Prisma.ViewCreateInput): Promise<View> {
    return prisma.view.create({ data });
  }

  async hasUserViewedAd(userId: string, adId: string): Promise<boolean> {
    const view = await prisma.view.findFirst({
      where: {
        user: userId,
        ad: adId,
      },
    });
    return !!view;
  }

  async countByAdId(adId: string): Promise<number> {
    return prisma.view.count({
      where: { ad: adId },
    });
  }
}

