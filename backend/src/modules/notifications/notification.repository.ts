import { prisma } from "../../lib/prisma.js";

export const createNotification = (data: {
  userId: number;
  letterId: number;
  type: "NEW_REPLY" | "ARTWORK_DELIVERED" | "LETTER_CLAIMED";
  title: string;
  message: string;
}) => {
  return prisma.notification.create({
    data: {
      userId: data.userId,
      letterId: data.letterId,
      type: data.type,
      title: data.title,
      message: data.message,
    },
  });
};

export const getNotificationsByUser = (userId: number, limit = 30) => {
  return prisma.notification.findMany({
    where: { userId },
    orderBy: { createdAt: "desc" },
    take: limit,
  });
};

export const getUnreadCount = (userId: number) => {
  return prisma.notification.count({
    where: {
      userId,
      isRead: false,
    },
  });
};

export const markNotificationAsRead = (id: number, userId: number) => {
  return prisma.notification.updateMany({
    where: {
      id,
      userId,
    },
    data: {
      isRead: true,
    },
  });
};

export const markLetterNotificationsAsRead = (letterId: number, userId: number) => {
  return prisma.notification.updateMany({
    where: {
      letterId,
      userId,
      isRead: false,
    },
    data: {
      isRead: true,
    },
  });
};
