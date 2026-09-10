import type { Request, Response } from "express";
import {
  getUserNotifications,
  markAsRead,
  markLetterAsRead,
} from "./notification.service.js";

export const getNotificationsController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;
  if (!userId) {
    response.status(401).json({ error: "Authentication required" });
    return;
  }

  try {
    const data = await getUserNotifications(userId);
    response.status(200).json(data);
  } catch (error) {
    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};

export const markNotificationAsReadController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;
  if (!userId) {
    response.status(401).json({ error: "Authentication required" });
    return;
  }

  const id = Number(request.params["id"]);
  if (!Number.isInteger(id) || id <= 0) {
    response.status(400).json({ error: "Invalid notification ID" });
    return;
  }

  try {
    const result = await markAsRead(id, userId);
    response.status(200).json(result);
  } catch (error) {
    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};

export const markLetterNotificationsAsReadController = async (
  request: Request,
  response: Response,
): Promise<void> => {
  const userId = request.auth?.userId;
  if (!userId) {
    response.status(401).json({ error: "Authentication required" });
    return;
  }

  const letterId = Number(request.params["letterId"]);
  if (!Number.isInteger(letterId) || letterId <= 0) {
    response.status(400).json({ error: "Invalid letter ID" });
    return;
  }

  try {
    const result = await markLetterAsRead(letterId, userId);
    response.status(200).json(result);
  } catch (error) {
    console.error(error);
    response.status(500).json({ error: "Something went wrong" });
  }
};
