import type { NextFunction, Request, Response } from "express";
import { SESSION_COOKIE_NAME } from "../modules/auth/auth.cookie.js";
import { getSession } from "../modules/auth/auth.session.service.js";

export const requireAuthentication = async (
  request: Request,
  response: Response,
  next: NextFunction,
): Promise<void> => {
  const token = request.cookies?.[SESSION_COOKIE_NAME];

  if (!token) {
    response.status(401).json({
      error: "Authentication required",
    });
    return;
  }

  try {
    const session = await getSession(token);

    if (!session) {
      response.status(401).json({
        error: "Invalid or expired session",
      });
      return;
    }

    request.auth = {
      userId: Number(session.user.id),
      sessionId: session.id,
    };

    next();
  } catch (error) {
    next(error);
  }
};

export const optionalAuthentication = async (
  request: Request,
  response: Response,
  next: NextFunction,
): Promise<void> => {
  const token = request.cookies?.[SESSION_COOKIE_NAME];

  if (!token) {
    next();
    return;
  }

  try {
    const session = await getSession(token);

    if (session) {
      request.auth = {
        userId: Number(session.user.id),
        sessionId: session.id,
      };
    }
  } catch {
    // Invalid session should not block public routes
  }

  next();
};