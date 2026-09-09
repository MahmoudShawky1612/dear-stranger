import type { Request, Response } from "express";
import { updateProfileSchema } from "./user.schema.js";
import {
  updateMyProfile,
  getPublicProfileByUsername,
  UserNotFoundError,
} from "./user.service.js";

export const updateMyProfileController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;

  if (!userId) {
    response.status(401).json({ error: "Authentication required" });
    return;
  }

  const result = updateProfileSchema.safeParse(request.body);

  if (!result.success) {
    response.status(400).json({
      error: "Invalid request body",
      details: result.error.issues,
    });
    return;
  }

  try {
    const user = await updateMyProfile(userId, result.data);

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
    if (error instanceof UserNotFoundError) {
      response.status(404).json({ error: error.message });
      return;
    }

    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};

export const getPublicProfileController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const username = request.params["username"];

  if (!username || typeof username !== "string") {
    response.status(400).json({ error: "Invalid username" });
    return;
  }

  try {
    const user = await getPublicProfileByUsername(username);

    response.status(200).json({
      user: {
        id: user.id,
        username: user.username,
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
    if (error instanceof UserNotFoundError) {
      response.status(404).json({ error: error.message });
      return;
    }

    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};