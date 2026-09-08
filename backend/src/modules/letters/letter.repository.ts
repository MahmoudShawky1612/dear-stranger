import { prisma } from "../../lib/prisma.js";
import type { CreateLetterInput } from "./letter.schema.js";

export const createLetter = (
  senderId: number,
  input: CreateLetterInput,
) => {
  return prisma.letter.create({
    data: {
      senderId,
      title: input.title,
      message: input.message,
      isAnonymous: input.isAnonymous,
    },
  });
};

export const claimLetter = (
  letterId: number,
  artistId: number,
  claimedAt: Date,
) => {
  return prisma.letter.updateManyAndReturn({
    where: {
      id: letterId,
      status: "AVAILABLE",
      artistId: null,
    },
    data: {
      artistId,
      status: "CLAIMED",
      claimedAt,
    },
  });
};

export const findAvailableLetters = () => {
  return prisma.letter.findMany({
    where: {
      status: "AVAILABLE",
    },
    orderBy: {
      createdAt: "desc",
    },
    include: {
      sender: {
        select: {
          id: true,
          username: true,
          displayName: true,
        },
      },
    },
  });
};

export const findClaimedLetterForArtist = (
  letterId: number,
  artistId: number,
) => {
  return prisma.letter.findFirst({
    where: {
      id: letterId,
      artistId,
      status: "CLAIMED",
    },
  });
};

export const findArtworkByLetterId = (letterId: number) => {
  return prisma.artwork.findUnique({
    where: {
      letterId,
    },
  });
};

export const createArtworkAndDeliverLetter = async (data: {
  letterId: number;
  storageKey: string;
  contentType: string;
  fileSizeBytes: number;
  isAnonymous: boolean;
  deliveredAt: Date;
}) => {
  return prisma.$transaction(async (transaction) => {
    const updatedLetters = await transaction.letter.updateManyAndReturn({
      where: {
        id: data.letterId,
        status: "CLAIMED",
      },
      data: {
        status: "DELIVERED",
        deliveredAt: data.deliveredAt,
      },
    });

    const letter = updatedLetters[0];

    if (!letter) {
      return null;
    }

    return transaction.artwork.create({
      data: {
        letterId: data.letterId,
        storageKey: data.storageKey,
        contentType: data.contentType,
        fileSizeBytes: data.fileSizeBytes,
        isAnonymous: data.isAnonymous,
      },
    });
  });
};

export const createArtworkUpload = (data: {
  letterId: number;
  artistId: number;
  storageKey: string;
  contentType: string;
  expectedSize: number;
  expiresAt: Date;
}) => {
  return prisma.artworkUpload.create({
    data: {
      letterId: data.letterId,
      artistId: data.artistId,
      storageKey: data.storageKey,
      contentType: data.contentType,
      expectedSize: data.expectedSize,
      expiresAt: data.expiresAt,
    },
  });
};

export const findArtworkUpload = (
  letterId: number,
  artistId: number,
  storageKey: string,
) => {
  return prisma.artworkUpload.findUnique({
    where: {
      storageKey,
    },
  });
};

export const deleteArtworkUpload = (storageKey: string) => {
  return prisma.artworkUpload.delete({
    where: {
      storageKey,
    },
  });
};

export const completeArtworkDelivery = async (data: {
  letterId: number;
  storageKey: string;
  contentType: string;
  fileSizeBytes: number;
  isAnonymous: boolean;
  deliveredAt: Date;
}) => {
  return prisma.$transaction(async (transaction) => {
    const updatedLetters = await transaction.letter.updateManyAndReturn({
      where: {
        id: data.letterId,
        status: "CLAIMED",
      },
      data: {
        status: "DELIVERED",
        deliveredAt: data.deliveredAt,
      },
    });

    const letter = updatedLetters[0];

    if (!letter) {
      return null;
    }

    const artwork = await transaction.artwork.create({
      data: {
        letterId: data.letterId,
        storageKey: data.storageKey,
        contentType: data.contentType,
        fileSizeBytes: data.fileSizeBytes,
        isAnonymous: data.isAnonymous,
      },
    });

    await transaction.artworkUpload.delete({
      where: {
        storageKey: data.storageKey,
      },
    });

    return artwork;
  });
};