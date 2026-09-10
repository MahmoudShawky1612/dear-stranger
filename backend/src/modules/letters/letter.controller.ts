import type { Request, Response } from "express";
import {
  claimLetter,
  createLetter,
  LetterNotAvailableError,
  CannotClaimOwnLetterError,
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
  ArtworkAlreadyDeliveredError,
  completeArtworkDelivery,
  LetterNotClaimedByArtistError,
  createArtworkUploadUrl,
  uploadArtworkDirect,
} from "./artwork.service.js";

import { createLetterSchema, paginationSchema } from "./letter.schema.js";
import {
  idsEqual,
  serializeArtwork,
  serializeUserPreview,
} from "./letter.serializer.js";
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
    if (error instanceof CannotClaimOwnLetterError) {
      response.status(400).json({
        error: error.message,
      });
      return;
    }

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

    const serializedLetters = await Promise.all(
      letters.map(async (letter) => {
        const isMine = idsEqual(request.auth?.userId, letter.senderId);
        return {
          id: letter.id,
          title: letter.title,
          message: letter.message,
          status: letter.status,
          isAnonymous: letter.isAnonymous,
          isMine,
          createdAt: letter.createdAt,
          sender:
            letter.isAnonymous && !isMine
              ? null
              : await serializeUserPreview(letter.sender),
        };
      }),
    );

    response.status(200).json({
      letters: serializedLetters,
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

export const uploadArtworkDirectController = async (
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

  const contentType = parseImageContentType(request.headers["content-type"]);
  if (!contentType) {
    response.status(400).json({
      error: "Only JPEG, PNG, and WebP images are supported",
    });
    return;
  }

  const body = request.body;
  if (!Buffer.isBuffer(body) || body.length === 0) {
    response.status(400).json({
      error: "Artwork file is required",
    });
    return;
  }

  try {
    const artwork = await uploadArtworkDirect(letterId, artistId, {
      contentType,
      body,
      isAnonymous: false,
    });

    response.status(201).json({
      artwork: serializeArtwork(artwork),
    });
  } catch (error) {
    if (error instanceof LetterNotClaimedByArtistError) {
      response.status(403).json({
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

    if (error instanceof ArtworkAlreadyDeliveredError) {
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

    if (error instanceof ArtworkAlreadyDeliveredError) {
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

    const serializedSender =
      letter.isAnonymous && !idsEqual(letter.senderId, userId)
        ? null
        : await serializeUserPreview(letter.sender);

    const serializedArtist = letter.artist
      ? await serializeUserPreview(letter.artist)
      : null;

    const serializedReplies = await Promise.all(
      letter.replies.map(async (reply) => {
        const replyIsSender = idsEqual(reply.authorId, letter.senderId);
        const shouldMaskAnonymousSender =
          letter.isAnonymous && replyIsSender && !idsEqual(letter.senderId, userId);

        if (shouldMaskAnonymousSender) {
          return {
            id: reply.id,
            message: reply.message,
            createdAt: reply.createdAt,
            author: {
              id: 0,
              username: "Anonymous",
              displayName: "Anonymous",
              avatarUrl: null,
            },
          };
        }

        return {
          id: reply.id,
          message: reply.message,
          createdAt: reply.createdAt,
          author: await serializeUserPreview(reply.author),
        };
      }),
    );

    response.status(200).json({
      letter: {
        id: letter.id,
        title: letter.title,
        message: letter.message,
        status: letter.status,
        isAnonymous: letter.isAnonymous,
        isMine: idsEqual(letter.senderId, userId),
        createdAt: letter.createdAt,
        claimedAt: letter.claimedAt,
        deliveredAt: letter.deliveredAt,
        sender: serializedSender,
        artist: serializedArtist,
        artwork: letter.artwork ? serializeArtwork(letter.artwork) : null,
        replies: serializedReplies,
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
        author: await serializeUserPreview(reply.author),
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

    const serializedLetters = await Promise.all(
      letters.map(async (letter) => ({
        id: letter.id,
        title: letter.title,
        message: letter.message,
        status: letter.status,
        isAnonymous: letter.isAnonymous,
        isMine: true,
        createdAt: letter.createdAt,
        claimedAt: letter.claimedAt,
        deliveredAt: letter.deliveredAt,
        artist: letter.artist ? await serializeUserPreview(letter.artist) : null,
        artwork: letter.artwork ? serializeArtwork(letter.artwork) : null,
        replyCount: letter._count.replies,
      })),
    );

    response.status(200).json({
      letters: serializedLetters,
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

    const serializedLetters = await Promise.all(
      letters.map(async (letter) => ({
        id: letter.id,
        title: letter.title,
        message: letter.message,
        status: letter.status,
        isAnonymous: letter.isAnonymous,
        isMine: false,
        createdAt: letter.createdAt,
        claimedAt: letter.claimedAt,
        deliveredAt: letter.deliveredAt,
        sender: letter.isAnonymous
          ? null
          : await serializeUserPreview(letter.sender),
        artwork: letter.artwork ? serializeArtwork(letter.artwork) : null,
        replyCount: letter._count.replies,
      })),
    );

    response.status(200).json({
      letters: serializedLetters,
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