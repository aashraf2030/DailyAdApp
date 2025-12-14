import { RequestRepository } from '../repositories/request.repository';
import { AdRepository } from '../repositories/ad.repository';
import { UserRepository } from '../repositories/user.repository';
import { RequestType, Prisma } from '@prisma/client';
import { NotFoundError, ForbiddenError } from '../utils/errors';

export class AuthorityService {
  private requestRepository: RequestRepository;
  private adRepository: AdRepository;
  private userRepository: UserRepository;

  constructor() {
    this.requestRepository = new RequestRepository();
    this.adRepository = new AdRepository();
    this.userRepository = new UserRepository();
  }

  async getDefaultRequests() {
    const requests = await this.requestRepository.findByType('Create');
    return this.formatRequests(requests);
  }

  async getRenewRequests() {
    const requests = await this.requestRepository.findByType('Renew');
    return this.formatRequests(requests);
  }

  async getMoneyRequests() {
    const requests = await this.requestRepository.findByType('Money');
    return requests.map(req => ({
      id: req.id,
      username: req.userRelation?.username || '',
      userphone: req.userRelation?.phone || '',
      views: 0, // Calculate from user views if needed
      money: req.param ? parseFloat(req.param) : 0,
      join: req.creation?.toISOString() || '',
    }));
  }

  async getMyRequests(userId: string) {
    const requests = await this.requestRepository.findByUserId(userId);
    return this.formatRequests(requests);
  }

  async handleRequest(requestId: string, approved: boolean, adminId: string) {
    const request = await this.requestRepository.findById(requestId);
    if (!request) {
      throw new NotFoundError('Request not found');
    }

    if (request.type === 'Create' && request.ad) {
      if (approved) {
        await this.adRepository.update(request.ad, {
          isPublished: true,
        });
      }
      await this.requestRepository.delete(requestId);
    } else if (request.type === 'Renew' && request.ad) {
      if (approved) {
        await this.adRepository.update(request.ad, {
          renewalDate: new Date(),
          views: 0, // Reset views on renewal
        });
      }
      await this.requestRepository.delete(requestId);
    } else if (request.type === 'Money') {
      if (approved && request.param) {
        const amount = parseFloat(request.param);
        const user = await this.userRepository.findById(request.user);
        if (user) {
          await this.userRepository.update(request.user, {
            points: {
              increment: new Prisma.Decimal(amount),
            },
          });
        }
      }
      await this.requestRepository.delete(requestId);
    }

    return { handled: true };
  }

  async deleteRequest(requestId: string, userId: string) {
    const request = await this.requestRepository.findById(requestId);
    if (!request) {
      throw new NotFoundError('Request not found');
    }

    if (request.user !== userId) {
      throw new ForbiddenError('Not authorized to delete this request');
    }

    await this.requestRepository.delete(requestId);
  }

  async pointsExchange(userId: string, points: number) {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new NotFoundError('User not found');
    }

    if (Number(user.points) < points) {
      throw new ForbiddenError('Insufficient points');
    }

    // Create money request
    await this.requestRepository.create({
      type: 'Money',
      creation: new Date(),
      param: points.toString(),
      user: { connect: { id: userId } },
    });

    return { message: 'Exchange request created' };
  }

  private formatRequests(requests: any[]) {
    return requests.map(req => {
      const ad = req.adRelation;
      return {
        reqid: req.id,
        adname: ad?.name || '',
        username: req.userRelation?.username || '',
        userphone: req.userRelation?.phone || '',
        path: ad?.path || '',
        image: ad?.image || '',
        target: ad?.targetViews || 0,
        type: ad?.type || '',
        category: ad?.category || '',
        views: ad?.views || 0,
        tier: '', // Calculate tier if needed
        creation: ad?.creationDate?.toISOString() || '',
        lastUpdate: ad?.renewalDate?.toISOString() || ad?.creationDate?.toISOString() || '',
      };
    });
  }
}

