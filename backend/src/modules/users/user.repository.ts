import { prisma } from "../../lib/prisma.js";

export const findUserById = (userId: number) => {
  return prisma.user.findUnique({
    where: {
      id: userId,
    },
  });
};

export const findUserByUsername = (username: string) => {
  return prisma.user.findUnique({
    where: {
      username,
    },
  });
};

export const findUserByEmail = (email: string) => {
  return prisma.user.findUnique({
    where: {
      email,
    },
  });
};

export const createUser = (data: {
  username: string;
  email: string;
  passwordHash: string;
}) => {
  return prisma.user.create({
    data: {
      username: data.username,
      email: data.email,
      passwordHash: data.passwordHash,
    },
  });
};

export const findUserByIdentifier = (identifier: string) => {
  return prisma.user.findFirst({
    where: {
      OR: [
        {
          username: identifier,
        },
        {
          email: identifier,
        },
      ],
    },
  });
};


export const updateUserProfile = (
  userId: number,
  data: {
    displayName?: string | null;
    bio?: string | null;
    location?: string | null;
    favoriteMedium?: string | null;
    currentlyDrawing?: string | null;
  },
) => {
  // Only include keys that were actually provided (not undefined)
  const updateData: {
    displayName?: string | null;
    bio?: string | null;
    location?: string | null;
    favoriteMedium?: string | null;
    currentlyDrawing?: string | null;
  } = {};

  if (data.displayName !== undefined) {
    updateData.displayName = data.displayName;
  }
  if (data.bio !== undefined) {
    updateData.bio = data.bio;
  }
  if (data.location !== undefined) {
    updateData.location = data.location;
  }
  if (data.favoriteMedium !== undefined) {
    updateData.favoriteMedium = data.favoriteMedium;
  }
  if (data.currentlyDrawing !== undefined) {
    updateData.currentlyDrawing = data.currentlyDrawing;
  }

  return prisma.user.update({
    where: { id: userId },
    data: updateData,
  });
};

const publicUserSelect = {
  id: true,
  username: true,
  displayName: true,
  bio: true,
  avatarUrl: true,
  location: true,
  favoriteMedium: true,
  currentlyDrawing: true,
  createdAt: true,
} as const;

export const findPublicUserByUsername = (username: string) => {
  return prisma.user.findFirst({
    where: {
      username: {
        equals: username.trim().toLowerCase(),
        mode: "insensitive",
      },
    },
    select: publicUserSelect,
  });
};

export const searchUsersByUsername = (query: string, limit: number) => {
  return prisma.user.findMany({
    where: {
      username: {
        contains: query,
        mode: "insensitive",
      },
    },
    orderBy: { username: "asc" },
    take: limit,
    select: publicUserSelect,
  });
};

export const findPublishedArtworksByArtistId = (
  artistId: number,
  params: { limit: number; cursor?: number },
) => {
  return prisma.artwork.findMany({
    where: {
      isPublished: true,
      isAnonymous: false,
      letter: { artistId },
      ...(params.cursor ? { id: { lt: params.cursor } } : {}),
    },
    orderBy: [{ publishedAt: "desc" }, { id: "desc" }],
    take: params.limit,
    select: {
      id: true,
      letterId: true,
      storageKey: true,
      publishedAt: true,
      createdAt: true,
      letter: {
        select: {
          title: true,
        },
      },
    },
  });
};

export const createGuestbookEntry = (data: {
  hostId: number;
  authorId: number;
  message: string;
}) => {
  return prisma.guestbookEntry.create({
    data: {
      hostId: data.hostId,
      authorId: data.authorId,
      message: data.message,
    },
    include: {
      author: {
        select: {
          id: true,
          username: true,
          displayName: true,
          avatarUrl: true,
        },
      },
    },
  });
};

export const findGuestbookEntries = (
  hostId: number,
  params: { limit: number; cursor?: number },
) => {
  return prisma.guestbookEntry.findMany({
    where: {
      hostId,
      ...(params.cursor ? { id: { lt: params.cursor } } : {}),
    },
    orderBy: [{ createdAt: "desc" }, { id: "desc" }],
    take: params.limit,
    include: {
      author: {
        select: {
          id: true,
          username: true,
          displayName: true,
          avatarUrl: true,
        },
      },
    },
  });
};

export const findGuestbookEntryById = (id: number) => {
  return prisma.guestbookEntry.findUnique({
    where: { id },
  });
};

export const deleteGuestbookEntry = (id: number) => {
  return prisma.guestbookEntry.delete({
    where: { id },
  });
};

export const updateUserAvatar = (userId: number, avatarUrl: string | null) => {
  return prisma.user.update({
    where: { id: userId },
    data: { avatarUrl },
  });
};