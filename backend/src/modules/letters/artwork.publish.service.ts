import { prisma } from "../../lib/prisma.js";

export class ArtworkNotFoundError extends Error {
  constructor() {
    super("Artwork not found");
    this.name = "ArtworkNotFoundError";
  }
}

export class ArtworkPublishNotAllowedError extends Error {
  constructor() {
    super("Only the artist who created the artwork can publish it");
    this.name = "ArtworkPublishNotAllowedError";
  }
}

export class ArtworkAlreadyPublishedError extends Error {
  constructor() {
    super("Artwork is already published");
    this.name = "ArtworkAlreadyPublishedError";
  }
}

export const publishArtwork = async (
  letterId: number,
  artistId: number,
) => {
  const artwork = await prisma.artwork.findUnique({
    where: {
      letterId,
    },
    include: {
      letter: {
        select: {
          artistId: true,
        },
      },
    },
  });

  if (!artwork) {
    throw new ArtworkNotFoundError();
  }

  if (artwork.letter.artistId !== artistId) {
    throw new ArtworkPublishNotAllowedError();
  }

  if (artwork.isPublished) {
    throw new ArtworkAlreadyPublishedError();
  }

  return prisma.artwork.update({
    where: {
      id: artwork.id,
    },
    data: {
      isPublished: true,
      publishedAt: new Date(),
    },
  });
};