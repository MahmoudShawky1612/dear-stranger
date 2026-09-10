import { GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

import { b2 } from "../../lib/b2.js";
import { prisma } from "../../lib/prisma.js";

const bucketName = process.env["B2_BUCKET_NAME"];

if (!bucketName) {
  throw new Error("Missing B2_BUCKET_NAME environment variable");
}

const ARTWORK_URL_TTL_SECONDS = 10 * 60;

export class ArtworkNotFoundError extends Error {
  constructor() {
    super("Artwork not found");
    this.name = "ArtworkNotFoundError";
  }
}

export class ArtworkAccessDeniedError extends Error {
  constructor() {
    super("You do not have access to this artwork");
    this.name = "ArtworkAccessDeniedError";
  }
}

export const signArtworkStorageKey = async (storageKey: string) => {
  const command = new GetObjectCommand({
    Bucket: bucketName,
    Key: storageKey,
  });

  const url = await getSignedUrl(b2, command, {
    expiresIn: ARTWORK_URL_TTL_SECONDS,
  });

  return {
    url,
    expiresIn: ARTWORK_URL_TTL_SECONDS,
  };
};

export const getArtworkAccessUrl = async (
  artworkId: number,
  userId: number,
) => {
  const artwork = await prisma.artwork.findUnique({
    where: {
      id: artworkId,
    },
    include: {
      letter: {
        select: {
          senderId: true,
          artistId: true,
        },
      },
    },
  });

  if (!artwork) {
    throw new ArtworkNotFoundError();
  }

  const isParticipant =
    artwork.letter.senderId === userId ||
    artwork.letter.artistId === userId;

  if (!artwork.isPublished && !isParticipant) {
    throw new ArtworkAccessDeniedError();
  }

  return signArtworkStorageKey(artwork.storageKey);
};