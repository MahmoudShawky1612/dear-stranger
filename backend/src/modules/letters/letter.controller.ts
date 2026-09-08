import type { Request, Response } from "express";
import { createLetterSchema } from "./letter.schema.js";
import {
  claimLetter,
  createLetter,
  LetterNotAvailableError,
  getAvailableLetters,
} from "./letter.service.js";


import { createArtworkUploadSchema } from "./artwork.schema.js";
import { completeArtworkSchema } from "./artwork.schema.js";
import {
  ArtworkUploadValidationError,
  completeArtworkDelivery,
  LetterNotClaimedByArtistError,
createArtworkUploadUrl,
} from "./artwork.service.js";

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
  _request: Request,
  response: Response,
): Promise<void> => {
  try {
    const letters = await getAvailableLetters();

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
    });
  } catch (error) {
    console.error(error);

    response.status(500).json({
      error: "Something went wrong",
    });
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