import type { Request, Response } from "express";
import { updateProfileSchema } from "./user.schema.js";
import {
  updateMyProfile,
  getPublicProfileByUsername,
  UserNotFoundError,
  createGuestbookEntry,
  getGuestbookEntries,
  deleteGuestbookEntry,
  GuestbookEntryNotFoundError,
  NotAllowedError,
} from "./user.service.js";
import { createGuestbookEntrySchema } from "./guestbook.schema.js";
import { paginationSchema } from "../letters/letter.schema.js";


import {
  createAvatarUploadSchema,
  completeAvatarSchema,
} from "./avatar.schema.js";
import {
  createAvatarUploadUrl,
  completeAvatarUpload,
  uploadAvatarDirect,
  removeAvatar,
  getAvatarAccessUrl,
  AvatarUploadValidationError,
} from "./avatar.service.js";

export const createAvatarUploadUrlController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;
  if (!userId) {
    response.status(401).json({ error: "Authentication required" });
    return;
  }

  const result = createAvatarUploadSchema.safeParse(request.body);
  if (!result.success) {
    response.status(400).json({
      error: "Invalid request body",
      details: result.error.issues,
    });
    return;
  }

  try {
    const upload = await createAvatarUploadUrl(userId, result.data);
    response.status(200).json(upload);
  } catch (error) {
    if (error instanceof UserNotFoundError) {
      response.status(404).json({ error: error.message });
      return;
    }
    if (error instanceof AvatarUploadValidationError) {
      response.status(400).json({ error: error.message });
      return;
    }
    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};

const parseImageContentType = (
  header: string | undefined,
): "image/jpeg" | "image/png" | "image/webp" | null => {
  const raw = (header ?? "").split(";")[0]?.trim().toLowerCase();
  if (raw === "image/jpg") return "image/jpeg";
  if (raw === "image/jpeg" || raw === "image/png" || raw === "image/webp") {
    return raw;
  }
  return null;
};

export const uploadAvatarDirectController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;
  if (!userId) {
    response.status(401).json({ error: "Authentication required" });
    return;
  }

  const contentType = parseImageContentType(request.headers["content-type"]);
  if (!contentType) {
    response.status(400).json({
      error: "Only JPEG, PNG, and WebP images are supported",
    });
    return;
  }

  const body = request.body;
  if (!Buffer.isBuffer(body) || body.length === 0) {
    response.status(400).json({ error: "Avatar file is required" });
    return;
  }

  try {
    const user = await uploadAvatarDirect(userId, { contentType, body });
    response.status(200).json({
      user: {
        id: user.id,
        username: user.username,
        displayName: user.displayName ?? "",
        avatarUrl: user.avatarUrl,
        bio: user.bio,
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
    if (error instanceof AvatarUploadValidationError) {
      response.status(400).json({ error: error.message });
      return;
    }
    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};

export const completeAvatarUploadController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;
  if (!userId) {
    response.status(401).json({ error: "Authentication required" });
    return;
  }

  const result = completeAvatarSchema.safeParse(request.body);
  if (!result.success) {
    response.status(400).json({
      error: "Invalid request body",
      details: result.error.issues,
    });
    return;
  }

  try {
    const user = await completeAvatarUpload(userId, result.data);
    response.status(200).json({
      user: {
        id: user.id,
        username: user.username,
        displayName: user.displayName ?? "",
        avatarUrl: user.avatarUrl,
        bio: user.bio,
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
    if (error instanceof AvatarUploadValidationError) {
      response.status(400).json({ error: error.message });
      return;
    }
    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};

export const removeAvatarController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;
  if (!userId) {
    response.status(401).json({ error: "Authentication required" });
    return;
  }

  try {
    const user = await removeAvatar(userId);
    response.status(200).json({
      user: {
        id: user.id,
        username: user.username,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
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
    const avatarUrl = await getAvatarAccessUrl(user.avatarUrl);

    response.status(200).json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        displayName: user.displayName,
        bio: user.bio,
        avatarUrl,
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
    const avatarUrl = await getAvatarAccessUrl(user.avatarUrl);

    response.status(200).json({
      user: {
        id: user.id,
        username: user.username,
        displayName: user.displayName,
        bio: user.bio,
        avatarUrl,
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

export const createGuestbookEntryController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;

  if (!userId) {
    response.status(401).json({ error: "Authentication required" });
    return;
  }

const usernameParam = request.params["username"];
const username = typeof usernameParam === "string" ? usernameParam : null;

if (!username) {
  response.status(400).json({ error: "Invalid username" });
  return;
}

  const result = createGuestbookEntrySchema.safeParse(request.body);

  if (!result.success) {
    response.status(400).json({
      error: "Invalid request body",
      details: result.error.issues,
    });
    return;
  }

  try {
    const entry = await createGuestbookEntry(username, userId, result.data);

    response.status(201).json({
      entry: {
        id: entry.id,
        message: entry.message,
        createdAt: entry.createdAt,
        author: {
          id: entry.author.id,
          username: entry.author.username,
          displayName: entry.author.displayName,
        },
      },
    });
  } catch (error) {
    if (error instanceof UserNotFoundError) {
      response.status(404).json({ error: error.message });
      return;
    }
    if (error instanceof NotAllowedError) {
      response.status(403).json({ error: error.message });
      return;
    }

    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};

export const getGuestbookEntriesController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const usernameParam = request.params["username"];
const username = typeof usernameParam === "string" ? usernameParam : null;

if (!username) {
  response.status(400).json({ error: "Invalid username" });
  return;
}

  const paginationResult = paginationSchema.safeParse(request.query);

  if (!paginationResult.success) {
    response.status(400).json({
      error: "Invalid pagination parameters",
      details: paginationResult.error.issues,
    });
    return;
  }

  try {
    const { entries, nextCursor } = await getGuestbookEntries(
      username,
      paginationResult.data,
    );

    response.status(200).json({
      entries: entries.map((entry) => ({
        id: entry.id,
        message: entry.message,
        createdAt: entry.createdAt,
        author: {
          id: entry.author.id,
          username: entry.author.username,
          displayName: entry.author.displayName,
        },
      })),
      nextCursor,
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

export const deleteGuestbookEntryController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;

  if (!userId) {
    response.status(401).json({ error: "Authentication required" });
    return;
  }

  const entryId = Number(request.params["id"]);

  if (!Number.isInteger(entryId) || entryId <= 0) {
    response.status(400).json({ error: "Invalid entry ID" });
    return;
  }

  try {
    await deleteGuestbookEntry(entryId, userId);
    response.status(204).send();
  } catch (error) {
    if (error instanceof GuestbookEntryNotFoundError) {
      response.status(404).json({ error: error.message });
      return;
    }
    if (error instanceof NotAllowedError) {
      response.status(403).json({ error: error.message });
      return;
    }

    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};