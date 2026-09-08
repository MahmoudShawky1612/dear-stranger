import type { Request, Response } from "express";
import { registerSchema, loginSchema, } from "./auth.schema.js";
import {
  registerUser,
  loginUser,
  InvalidCredentialsError,
  RegistrationConflictError,
} from "./auth.service.js";
import { SESSION_COOKIE_NAME, sessionCookieOptions } from "./auth.cookie.js";
import { getUserById } from "../users/user.service.js";
import { deleteUserSession } from "./auth.session.service.js";

export const registerController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const result = registerSchema.safeParse(request.body);

  if (!result.success) {
    response.status(400).json({
      error: "Invalid request body",
      details: result.error.issues,
    });
    return;
  }

  try {
    const { user, session } = await registerUser(result.data);

    response.cookie(SESSION_COOKIE_NAME, session.token, {
      httpOnly: true,
      secure: process.env["NODE_ENV"] === "production",
      sameSite: "strict",
      path: "/",
      expires: session.expiresAt,
    });

    response.status(201).json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        displayName: user.displayName,
        bio: user.bio,
        avatarUrl: user.avatarUrl,
        location: user.location,
        favoriteMedium: user.favoriteMedium,
        currentlyDrawing: user.currentlyDrawing,
        createdAt: user.createdAt,
      },
    });
  } catch (error) {
    if (error instanceof RegistrationConflictError) {
      response.status(409).json({
        error: error.message,
      });
      return;
    }

    console.error(error);

    response.status(500).json({
      error: "Something went wrong",
    });
  }
};

export const getCurrentUserController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;

  if (!userId) {
    response.status(401).json({
      error: "Authentication required",
    });
    return;
  }

  const user = await getUserById(userId);

  if (!user) {
    response.status(401).json({
      error: "User account no longer exists",
    });
    return;
  }

  response.status(200).json({
    user: {
      id: user.id,
      username: user.username,
      email: user.email,
      displayName: user.displayName,
      bio: user.bio,
      avatarUrl: user.avatarUrl,
      location: user.location,
      favoriteMedium: user.favoriteMedium,
      currentlyDrawing: user.currentlyDrawing,
      createdAt: user.createdAt,
    },
  });
};

export const loginController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const result = loginSchema.safeParse(request.body);

  if (!result.success) {
    response.status(400).json({
      error: "Invalid request body",
      details: result.error.issues,
    });
    return;
  }

  try {
    const { user, session } = await loginUser(result.data);

    response.cookie(SESSION_COOKIE_NAME, session.token, {
      ...sessionCookieOptions,
      expires: session.expiresAt,
    });

    response.status(200).json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        displayName: user.displayName,
        bio: user.bio,
        avatarUrl: user.avatarUrl,
        location: user.location,
        favoriteMedium: user.favoriteMedium,
        currentlyDrawing: user.currentlyDrawing,
        createdAt: user.createdAt,
      },
    });
  } catch (error) {
    if (error instanceof InvalidCredentialsError) {
      response.status(401).json({
        error: error.message,
      });
      return;
    }

    console.error(error);

    response.status(500).json({
      error: "Something went wrong",
    });
  }
};


export const logoutController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const token = request.cookies?.[SESSION_COOKIE_NAME];

  if (token) {
    await deleteUserSession(token);
  }

  response.clearCookie(SESSION_COOKIE_NAME, sessionCookieOptions);

  response.status(204).send();
};