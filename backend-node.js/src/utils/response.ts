import { Response } from 'express';

export interface ApiResponse<T = any> {
  status: 'Success' | 'Error';
  message?: string;
  data?: T;
  error?: string;
}

export const sendSuccess = <T>(
  res: Response,
  data?: T,
  message?: string,
  statusCode = 200
): Response => {
  const response: ApiResponse<T> = {
    status: 'Success',
    ...(message && { message }),
    ...(data !== undefined && { data }),
  };
  return res.status(statusCode).json(response);
};

export const sendError = (
  res: Response,
  message: string,
  statusCode = 500
): Response => {
  const response: ApiResponse = {
    status: 'Error',
    error: message,
  };
  return res.status(statusCode).json(response);
};

