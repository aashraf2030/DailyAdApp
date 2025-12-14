import prisma from '../config/database';
import { User, Prisma } from '@prisma/client';

export class UserRepository {
  async create(data: Prisma.UserCreateInput): Promise<User> {
    return prisma.user.create({ data });
  }

  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { id },
    });
  }

  async findByUsername(username: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { username },
    });
  }

  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { email },
    });
  }

  async update(id: string, data: Prisma.UserUpdateInput): Promise<User> {
    return prisma.user.update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<User> {
    return prisma.user.update({
      where: { id },
      data: { isDeleted: true },
    });
  }

  async getLeaderboard(limit = 10, currentUserId?: string) {
    const users = await prisma.user.findMany({
      where: {
        isDeleted: false,
      },
      orderBy: {
        points: 'desc',
      },
      take: limit,
      select: {
        id: true,
        username: true,
        points: true,
      },
    });

    return users.map((user, index) => ({
      rank: index + 1,
      username: user.username,
      points: Number(user.points),
      isCurrentUser: currentUserId ? user.id === currentUserId : false,
    }));
  }
}

