import { AdRepository } from '../repositories/ad.repository';
import { RequestRepository } from '../repositories/request.repository';
import { NotFoundError, ForbiddenError } from '../utils/errors';
import { Category, AdType } from '@prisma/client';

export class AdService {
  private adRepository: AdRepository;
  private requestRepository: RequestRepository;

  constructor() {
    this.adRepository = new AdRepository();
    this.requestRepository = new RequestRepository();
  }

  async createAd(data: {
    name: string;
    path: string;
    image: string;
    type: AdType;
    category: Category;
    targetViews: number;
    keywords: string;
    userId: string;
  }) {
    const ad = await this.adRepository.create({
      name: data.name,
      path: data.path,
      image: data.image,
      type: data.type,
      category: data.category,
      targetViews: data.targetViews,
      keywords: data.keywords,
      views: 0,
      isPublished: false,
      creationDate: new Date(),
      user: { connect: { id: data.userId } },
    });

    // Create request for admin approval
    await this.requestRepository.create({
      type: 'Create',
      creation: new Date(),
      param: JSON.stringify({ adId: ad.id }),
      ad: { connect: { id: ad.id } },
      user: { connect: { id: data.userId } },
    });

    return {
      id: ad.id,
      name: ad.name,
      path: ad.path,
      image: ad.image,
      type: ad.type,
      category: ad.category,
      targetViews: ad.targetViews,
      views: ad.views,
      keywords: ad.keywords,
      isPublished: ad.isPublished,
      creationDate: ad.creationDate,
    };
  }

  async editAd(adId: string, userId: string, data: {
    name?: string;
    path?: string;
    image?: string;
    type?: AdType;
    category?: Category;
    targetViews?: number;
    keywords?: string;
  }) {
    const ad = await this.adRepository.findById(adId);
    if (!ad) {
      throw new NotFoundError('Ad not found');
    }

    if (ad.userid !== userId) {
      throw new ForbiddenError('Not authorized to edit this ad');
    }

    const updatedAd = await this.adRepository.update(adId, {
      ...(data.name && { name: data.name }),
      ...(data.path && { path: data.path }),
      ...(data.image && { image: data.image }),
      ...(data.type && { type: data.type }),
      ...(data.category && { category: data.category }),
      ...(data.targetViews && { targetViews: data.targetViews }),
      ...(data.keywords && { keywords: data.keywords }),
    });

    return {
      id: updatedAd.id,
      name: updatedAd.name,
      path: updatedAd.path,
      image: updatedAd.image,
      type: updatedAd.type,
      category: updatedAd.category,
      targetViews: updatedAd.targetViews,
      views: updatedAd.views,
      keywords: updatedAd.keywords,
      isPublished: updatedAd.isPublished,
      creationDate: updatedAd.creationDate,
      renewalDate: updatedAd.renewalDate,
    };
  }

  async getUserAds(userId: string) {
    const ads = await this.adRepository.findByUserId(userId);
    return ads.map(ad => ({
      id: ad.id,
      name: ad.name,
      path: ad.path,
      image: ad.image,
      type: ad.type,
      category: ad.category,
      targetViews: ad.targetViews,
      views: ad.views,
      keywords: ad.keywords,
      isPublished: ad.isPublished,
      creationDate: ad.creationDate,
      renewalDate: ad.renewalDate,
      lastUpdate: ad.renewalDate || ad.creationDate,
    }));
  }

  async fetchCategoryAds(category: Category, excludeUserId?: string) {
    const ads = await this.adRepository.findByCategory(category, excludeUserId);
    return ads.map(ad => ({
      id: ad.id,
      name: ad.name,
      path: ad.path,
      image: ad.image,
      type: ad.type,
      category: ad.category,
      targetViews: ad.targetViews,
      views: ad.views,
      keywords: ad.keywords,
      isPublished: ad.isPublished,
      creationDate: ad.creationDate,
      renewalDate: ad.renewalDate,
      lastUpdate: ad.renewalDate || ad.creationDate,
      userid: ad.userid,
    }));
  }

  async renewAd(adId: string, userId: string) {
    const ad = await this.adRepository.findById(adId);
    if (!ad) {
      throw new NotFoundError('Ad not found');
    }

    if (ad.userid !== userId) {
      throw new ForbiddenError('Not authorized to renew this ad');
    }

    // Create renewal request
    await this.requestRepository.create({
      type: 'Renew',
      creation: new Date(),
      param: JSON.stringify({ adId }),
      ad: { connect: { id: adId } },
      user: { connect: { id: userId } },
    });

    return { message: 'Renewal request created' };
  }
}

