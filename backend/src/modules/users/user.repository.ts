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

export const findPublicUserByUsername = (username: string) => {
  return prisma.user.findUnique({
    where: { username },
    select: {
      id: true,
      username: true,
      displayName: true,
      bio: true,
      avatarUrl: true,
      location: true,
      favoriteMedium: true,
      currentlyDrawing: true,
      createdAt: true,
    },
  });
};