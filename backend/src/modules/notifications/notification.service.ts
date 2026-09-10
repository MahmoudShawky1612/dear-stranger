import {
  createNotification,
  getNotificationsByUser,
  getUnreadCount,
  markNotificationAsRead,
  markLetterNotificationsAsRead,
} from "./notification.repository.js";
import { sendNotificationToUser } from "../../lib/websocket.js";

export const createAndDispatchNotification = async (data: {
  userId: number;
  letterId: number;
  type: "NEW_REPLY" | "ARTWORK_DELIVERED" | "LETTER_CLAIMED";
  title: string;
  message: string;
}) => {
  const notification = await createNotification(data);
  const unreadCount = await getUnreadCount(data.userId);

  sendNotificationToUser(data.userId, {
    type: "notification",
    notification: {
      id: notification.id,
      letterId: notification.letterId,
      type: notification.type,
      title: notification.title,
      message: notification.message,
      createdAt: notification.createdAt,
    },
    unreadCount,
  });

  return notification;
};

export const getUserNotifications = async (userId: number) => {
  const notifications = await getNotificationsByUser(userId);
  const unreadCount = await getUnreadCount(userId);
  return { notifications, unreadCount };
};

export const markAsRead = async (id: number, userId: number) => {
  await markNotificationAsRead(id, userId);
  const unreadCount = await getUnreadCount(userId);
  sendNotificationToUser(userId, {
    type: "unread_count",
    unreadCount,
  });
  return { unreadCount };
};

export const markLetterAsRead = async (letterId: number, userId: number) => {
  await markLetterNotificationsAsRead(letterId, userId);
  const unreadCount = await getUnreadCount(userId);
  sendNotificationToUser(userId, {
    type: "unread_count",
    unreadCount,
  });
  return { unreadCount };
};
