import type { Request, Response } from "express";
import {
  claimLetter,
  createLetter,
  LetterNotAvailableError,
  getAvailableLetters,
  getMySentLetters,
  getMyClaimedLetters,
} from "./letter.service.js";
import {
  ArtworkAccessDeniedError,
  ArtworkNotFoundError,
  getArtworkAccessUrl,
} from "./artwork.access.service.js";
import {
  createReply,
  getLetterById,
  LetterNotFoundError,
  LetterNotDeliveredError,
  NotParticipantError,
} from "./reply.service.js";

import {
  publishArtwork,
  ArtworkPublishNotAllowedError,
  ArtworkAlreadyPublishedError,
} from "./artwork.publish.service.js";

import { createReplySchema } from "./reply.schema.js";

import { createArtworkUploadSchema } from "./artwork.schema.js";
import { completeArtworkSchema } from "./artwork.schema.js";
import {
  ArtworkUploadValidationError,
  completeArtworkDelivery,
  LetterNotClaimedByArtistError,
createArtworkUploadUrl,
} from "./artwork.service.js";

import { createLetterSchema, paginationSchema } from "./letter.schema.js";
export const createLetterController = async (
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

  const result = createLetterSchema.safeParse(request.body);

  if (!result.success) {
    response.status(400).json({
      error: "Invalid request body",
      details: result.error.issues,
    });
    return;
  }

  try {
    const letter = await createLetter(userId, result.data);

    response.status(201).json({
      letter: {
        id: letter.id,
        title: letter.title,
        message: letter.message,
        status: letter.status,
        isAnonymous: letter.isAnonymous,
        createdAt: letter.createdAt,
      },
    });
  } catch (error) {
    console.error(error);

    response.status(500).json({
      error: "Something went wrong",
    });
  }
};

export const claimLetterController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const artistId = request.auth?.userId;

  if (!artistId) {
    response.status(401).json({
      error: "Authentication required",
    });
    return;
  }

  const letterId = Number(request.params["id"]);

  if (!Number.isInteger(letterId) || letterId <= 0) {
    response.status(400).json({
      error: "Invalid letter ID",
    });
    return;
  }

  try {
    const letter = await claimLetter(letterId, artistId);

    response.status(200).json({
      letter: {
        id: letter.id,
        title: letter.title,
        message: letter.message,
        status: letter.status,
        isAnonymous: letter.isAnonymous,
        createdAt: letter.createdAt,
        claimedAt: letter.claimedAt,
      },
    });
  } catch (error) {
    if (error instanceof LetterNotAvailableError) {
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

export const getAvailableLettersController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const paginationResult = paginationSchema.safeParse(request.query);

  if (!paginationResult.success) {
    response.status(400).json({
      error: "Invalid pagination parameters",
      details: paginationResult.error.issues,
    });
    return;
  }

  try {
    const { letters, nextCursor } = await getAvailableLetters(
      paginationResult.data,
    );

    response.status(200).json({
      letters: letters.map((letter) => ({
        id: letter.id,
        title: letter.title,
        message: letter.message,
        status: letter.status,
        isAnonymous: letter.isAnonymous,
        createdAt: letter.createdAt,
        sender: letter.isAnonymous
          ? null
          : {
              id: letter.sender.id,
              username: letter.sender.username,
              displayName: letter.sender.displayName,
            },
      })),
      nextCursor,
    });
  } catch (error) {
    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};

export const createArtworkUploadUrlController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const artistId = request.auth?.userId;

  if (!artistId) {
    response.status(401).json({
      error: "Authentication required",
    });
    return;
  }

  const letterId = Number(request.params["id"]);

  if (!Number.isInteger(letterId) || letterId <= 0) {
    response.status(400).json({
      error: "Invalid letter ID",
    });
    return;
  }

  const result = createArtworkUploadSchema.safeParse(request.body);

  if (!result.success) {
    response.status(400).json({
      error: "Invalid request body",
      details: result.error.issues,
    });
    return;
  }

  try {
    const upload = await createArtworkUploadUrl(
      letterId,
      artistId,
      result.data,
    );

    response.status(200).json(upload);
  } catch (error) {
    if (error instanceof LetterNotClaimedByArtistError) {
      response.status(403).json({
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

export const completeArtworkDeliveryController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const artistId = request.auth?.userId;

  if (!artistId) {
    response.status(401).json({
      error: "Authentication required",
    });
    return;
  }

  const letterId = Number(request.params["id"]);

  if (!Number.isInteger(letterId) || letterId <= 0) {
    response.status(400).json({
      error: "Invalid letter ID",
    });
    return;
  }

  const result = completeArtworkSchema.safeParse(request.body);

  if (!result.success) {
    response.status(400).json({
      error: "Invalid request body",
      details: result.error.issues,
    });
    return;
  }

  try {
    const artwork = await completeArtworkDelivery(
      letterId,
      artistId,
      result.data,
    );

    response.status(201).json({
      artwork: {
        id: artwork.id,
        letterId: artwork.letterId,
        storageKey: artwork.storageKey,
        contentType: artwork.contentType,
        fileSizeBytes: artwork.fileSizeBytes,
        isAnonymous: artwork.isAnonymous,
        isPublished: artwork.isPublished,
        createdAt: artwork.createdAt,
      },
    });
  } catch (error) {
    if (error instanceof LetterNotClaimedByArtistError) {
      response.status(409).json({
        error: error.message,
      });
      return;
    }

    if (error instanceof ArtworkUploadValidationError) {
      response.status(400).json({
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

export const getLetterController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;

  if (!userId) {
    response.status(401).json({ error: "Authentication required" });
    return;
  }

  const letterId = Number(request.params["id"]);

  if (!Number.isInteger(letterId) || letterId <= 0) {
    response.status(400).json({ error: "Invalid letter ID" });
    return;
  }

  try {
    const letter = await getLetterById(letterId, userId);

    response.status(200).json({
      letter: {
        id: letter.id,
        title: letter.title,
        message: letter.message,
        status: letter.status,
        isAnonymous: letter.isAnonymous,
        createdAt: letter.createdAt,
        claimedAt: letter.claimedAt,
        deliveredAt: letter.deliveredAt,
        sender: letter.isAnonymous
          ? null
          : {
              id: letter.sender.id,
              username: letter.sender.username,
              displayName: letter.sender.displayName,
            },
        artist: letter.artist
          ? {
              id: letter.artist.id,
              username: letter.artist.username,
              displayName: letter.artist.displayName,
            }
          : null,
        artwork: letter.artwork
          ? {
              id: letter.artwork.id,
              storageKey: letter.artwork.storageKey,
              contentType: letter.artwork.contentType,
              fileSizeBytes: letter.artwork.fileSizeBytes,
              isAnonymous: letter.artwork.isAnonymous,
              createdAt: letter.artwork.createdAt,
            }
          : null,
        replies: letter.replies.map((reply) => ({
          id: reply.id,
          message: reply.message,
          createdAt: reply.createdAt,
          author: {
            id: reply.author.id,
            username: reply.author.username,
            displayName: reply.author.displayName,
          },
        })),
      },
    });
  } catch (error) {
    if (error instanceof LetterNotFoundError) {
      response.status(404).json({ error: error.message });
      return;
    }
    if (error instanceof NotParticipantError) {
      response.status(403).json({ error: error.message });
      return;
    }

    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};

export const createReplyController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;

  if (!userId) {
    response.status(401).json({ error: "Authentication required" });
    return;
  }

  const letterId = Number(request.params["id"]);

  if (!Number.isInteger(letterId) || letterId <= 0) {
    response.status(400).json({ error: "Invalid letter ID" });
    return;
  }

  const result = createReplySchema.safeParse(request.body);

  if (!result.success) {
    response.status(400).json({
      error: "Invalid request body",
      details: result.error.issues,
    });
    return;
  }

  try {
    const reply = await createReply(letterId, userId, result.data);

    response.status(201).json({
      reply: {
        id: reply.id,
        message: reply.message,
        createdAt: reply.createdAt,
        author: {
          id: reply.author.id,
          username: reply.author.username,
          displayName: reply.author.displayName,
        },
      },
    });
  } catch (error) {
    if (error instanceof LetterNotFoundError) {
      response.status(404).json({ error: error.message });
      return;
    }
    if (error instanceof LetterNotDeliveredError) {
      response.status(409).json({ error: error.message });
      return;
    }
    if (error instanceof NotParticipantError) {
      response.status(403).json({ error: error.message });
      return;
    }

    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};

export const getMySentLettersController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;

  if (!userId) {
    response.status(401).json({ error: "Authentication required" });
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
    const { letters, nextCursor } = await getMySentLetters(
      userId,
      paginationResult.data,
    );

    response.status(200).json({
      letters: letters.map((letter) => ({
        id: letter.id,
        title: letter.title,
        message: letter.message,
        status: letter.status,
        isAnonymous: letter.isAnonymous,
        createdAt: letter.createdAt,
        claimedAt: letter.claimedAt,
        deliveredAt: letter.deliveredAt,
        artist: letter.artist
          ? {
              id: letter.artist.id,
              username: letter.artist.username,
              displayName: letter.artist.displayName,
            }
          : null,
        artwork: letter.artwork
          ? {
              id: letter.artwork.id,
              storageKey: letter.artwork.storageKey,
              contentType: letter.artwork.contentType,
              fileSizeBytes: letter.artwork.fileSizeBytes,
              isAnonymous: letter.artwork.isAnonymous,
              createdAt: letter.artwork.createdAt,
            }
          : null,
        replyCount: letter._count.replies,
      })),
      nextCursor,
    });
  } catch (error) {
    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};

export const getMyClaimedLettersController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;

  if (!userId) {
    response.status(401).json({ error: "Authentication required" });
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
    const { letters, nextCursor } = await getMyClaimedLetters(
      userId,
      paginationResult.data,
    );

    response.status(200).json({
      letters: letters.map((letter) => ({
        id: letter.id,
        title: letter.title,
        message: letter.message,
        status: letter.status,
        isAnonymous: letter.isAnonymous,
        createdAt: letter.createdAt,
        claimedAt: letter.claimedAt,
        deliveredAt: letter.deliveredAt,
        sender: letter.isAnonymous
          ? null
          : {
              id: letter.sender.id,
              username: letter.sender.username,
              displayName: letter.sender.displayName,
            },
        artwork: letter.artwork
          ? {
              id: letter.artwork.id,
              storageKey: letter.artwork.storageKey,
              contentType: letter.artwork.contentType,
              fileSizeBytes: letter.artwork.fileSizeBytes,
              isAnonymous: letter.artwork.isAnonymous,
              createdAt: letter.artwork.createdAt,
            }
          : null,
        replyCount: letter._count.replies,
      })),
      nextCursor,
    });
  } catch (error) {
    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};

export const getArtworkAccessUrlController = async (
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

  const artworkId = Number(request.params["artworkId"]);

  if (!Number.isInteger(artworkId) || artworkId <= 0) {
    response.status(400).json({
      error: "Invalid artwork ID",
    });
    return;
  }

  try {
    const result = await getArtworkAccessUrl(artworkId, userId);

    response.status(200).json(result);
  } catch (error) {
    if (error instanceof ArtworkNotFoundError) {
      response.status(404).json({
        error: error.message,
      });
      return;
    }

    if (error instanceof ArtworkAccessDeniedError) {
      response.status(403).json({
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

export const publishArtworkController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const artistId = request.auth?.userId;

  if (!artistId) {
    response.status(401).json({
      error: "Authentication required",
    });
    return;
  }

  const letterId = Number(request.params["id"]);

  if (!Number.isInteger(letterId) || letterId <= 0) {
    response.status(400).json({
      error: "Invalid letter ID",
    });
    return;
  }

  try {
    const artwork = await publishArtwork(letterId, artistId);

    response.status(200).json({
      artwork: {
        id: artwork.id,
        letterId: artwork.letterId,
        isPublished: artwork.isPublished,
        publishedAt: artwork.publishedAt,
      },
    });
  } catch (error) {
    if (error instanceof ArtworkNotFoundError) {
      response.status(404).json({
        error: error.message,
      });
      return;
    }

    if (error instanceof ArtworkPublishNotAllowedError) {
      response.status(403).json({
        error: error.message,
      });
      return;
    }

    if (error instanceof ArtworkAlreadyPublishedError) {
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