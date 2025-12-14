import { UserRepository } from '../repositories/user.repository';
import { SessionRepository } from '../repositories/session.repository';
import { hashPassword, verifyPassword } from '../utils/password';
import { generateToken } from '../utils/jwt';
import { ConflictError, UnauthorizedError, NotFoundError } from '../utils/errors';
import { v4 as uuidv4 } from 'uuid';

export class AuthService {
  private userRepository: UserRepository;
  private sessionRepository: SessionRepository;

  constructor() {
    this.userRepository = new UserRepository();
    this.sessionRepository = new SessionRepository();
  }

  async register(data: {
    fullname: string;
    username: string;
    email: string;
    password: string;
    phone?: string;
  }) {
    // Check if username exists
    const existingUser = await this.userRepository.findByUsername(data.username);
    if (existingUser) {
      throw new ConflictError('Username already exists');
    }

    // Check if email exists
    const existingEmail = await this.userRepository.findByEmail(data.email);
    if (existingEmail) {
      throw new ConflictError('Email already exists');
    }

    // Hash password (SHA-256 as Flutter sends)
    const hashedPassword = hashPassword(data.password);
    const verificationCode = uuidv4().substring(0, 6);

    // Create user
    const user = await this.userRepository.create({
      fullname: data.fullname,
      username: data.username,
      email: data.email,
      password: hashedPassword,
      phone: data.phone,
      points: 0,
      joinDate: new Date(),
      isVerified: false,
      isAdmin: false,
      isDeleted: false,
      verification: verificationCode,
    });

    // Generate token
    const token = generateToken({
      id: user.id,
      username: user.username,
      isAdmin: user.isAdmin,
      isVerified: user.isVerified,
    });

    // Create session
    await this.sessionRepository.create({
      user: { connect: { id: user.id } },
      token,
    });

    return {
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        fullname: user.fullname,
        phone: user.phone,
        points: Number(user.points),
        isVerified: user.isVerified,
        isAdmin: user.isAdmin,
      },
    };
  }

  async login(username: string, password: string) {
    const user = await this.userRepository.findByUsername(username);
    if (!user || user.isDeleted) {
      throw new UnauthorizedError('Invalid credentials');
    }

    if (!verifyPassword(password, user.password)) {
      throw new UnauthorizedError('Invalid credentials');
    }

    // Generate token
    const token = generateToken({
      id: user.id,
      username: user.username,
      isAdmin: user.isAdmin,
      isVerified: user.isVerified,
    });

    // Create session
    await this.sessionRepository.create({
      user: { connect: { id: user.id } },
      token,
    });

    return {
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        fullname: user.fullname,
        phone: user.phone,
        points: Number(user.points),
        isVerified: user.isVerified,
        isAdmin: user.isAdmin,
      },
    };
  }

  async logout(token: string) {
    await this.sessionRepository.deleteByToken(token);
  }

  async getProfile(userId: string) {
    const user = await this.userRepository.findById(userId);
    if (!user || user.isDeleted) {
      throw new NotFoundError('User not found');
    }

    return {
      id: user.id,
      username: user.username,
      email: user.email,
      fullname: user.fullname,
      phone: user.phone,
      points: Number(user.points),
      isVerified: user.isVerified,
      isAdmin: user.isAdmin,
      joinDate: user.joinDate,
    };
  }

  async deleteUser(userId: string) {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new NotFoundError('User not found');
    }

    // Delete all sessions
    await this.sessionRepository.deleteByUserId(userId);

    // Soft delete user
    await this.userRepository.delete(userId);
  }

  async sendVerificationCode(userId: string) {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new NotFoundError('User not found');
    }

    const verificationCode = uuidv4().substring(0, 6);
    await this.userRepository.update(userId, {
      verification: verificationCode,
    });

    // In production, send email here
    return { code: verificationCode }; // For development only
  }

  async verifyEmail(userId: string, code: string) {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new NotFoundError('User not found');
    }

    if (user.verification !== code) {
      throw new UnauthorizedError('Invalid verification code');
    }

    await this.userRepository.update(userId, {
      isVerified: true,
    });

    return { verified: true };
  }

  async resetPassword(email: string) {
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      // Don't reveal if email exists
      return { message: 'If email exists, reset code sent' };
    }

    const resetCode = uuidv4().substring(0, 6);
    await this.userRepository.update(user.id, {
      verification: resetCode,
    });

    // In production, send email here
    return { code: resetCode }; // For development only
  }

  async validateResetCode(email: string, code: string) {
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      throw new NotFoundError('User not found');
    }

    if (user.verification !== code) {
      throw new UnauthorizedError('Invalid reset code');
    }

    return { valid: true };
  }

  async changePassword(userId: string, oldPassword: string, newPassword: string) {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new NotFoundError('User not found');
    }

    if (!verifyPassword(oldPassword, user.password)) {
      throw new UnauthorizedError('Invalid old password');
    }

    const hashedPassword = hashPassword(newPassword);
    await this.userRepository.update(userId, {
      password: hashedPassword,
    });
  }
}

