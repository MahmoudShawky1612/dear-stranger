import { prisma } from "../../lib/prisma.js";

export const createSession = (data: {
  userId: number;
  tokenHash: string;
  expiresAt: Date;
}) => {
  return prisma.session.create({
    data: {
      userId: data.userId,
      tokenHash: data.tokenHash,
      expiresAt: data.expiresAt,
    },
  });
};

export const findSessionByTokenHash = (tokenHash: string) => {
  return prisma.session.findUnique({
    where: {
      tokenHash,
    },
    include: {
      user: true,
    },
  });
};

export const updateSessionLastUsedAt = (sessionId: string) => {
  return prisma.session.update({
    where: {
      id: sessionId,
    },
    data: {
      lastUsedAt: new Date(),
    },
  });
};

export const deleteSessionById = (sessionId: string) => {
  return prisma.session.delete({
    where: {
      id: sessionId,
    },
  });
};