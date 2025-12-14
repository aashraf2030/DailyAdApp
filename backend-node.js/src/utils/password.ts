import crypto from 'crypto';

/**
 * Hash password using SHA-256 (as Flutter app sends SHA-256 hashed passwords)
 */
export const hashPassword = (password: string): string => {
  return crypto.createHash('sha256').update(password).digest('hex');
};

/**
 * Verify password by comparing SHA-256 hashes
 */
export const verifyPassword = (password: string, hashedPassword: string): boolean => {
  const hashed = hashPassword(password);
  return hashed === hashedPassword;
};

