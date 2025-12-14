import { ViewRepository } from '../repositories/view.repository';
import { AdRepository } from '../repositories/ad.repository';
import { NotFoundError, ConflictError } from '../utils/errors';
import { Prisma } from '@prisma/client';

export class ViewService {
  private viewRepository: ViewRepository;
  private adRepository: AdRepository;

  constructor() {
    this.viewRepository = new ViewRepository();
    this.adRepository = new AdRepository();
  }

  async watchAd(adId: string, userId: string) {
    const ad = await this.adRepository.findById(adId);
    if (!ad) {
      throw new NotFoundError('Ad not found');
    }

    if (!ad.isPublished) {
      throw new NotFoundError('Ad not found');
    }

    // Check if user already viewed this ad
    const hasViewed = await this.viewRepository.hasUserViewedAd(userId, adId);
    if (hasViewed) {
      throw new ConflictError('Ad already viewed');
    }

    // Calculate points (example: 0.1 points per view)
    const points = new Prisma.Decimal(0.1);

    // Create view record
    await this.viewRepository.create({
      ad: { connect: { id: adId } },
      user: { connect: { id: userId } },
      time: new Date(),
      points,
    });

    // Increment ad views
    await this.adRepository.incrementViews(adId);

    return { points: Number(points) };
  }
}

