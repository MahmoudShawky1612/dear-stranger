import { Router } from "express";
import { requireAuthentication } from "../../middleware/auth.middleware.js";
import {
  getNotificationsController,
  markNotificationAsReadController,
  markLetterNotificationsAsReadController,
} from "./notification.controller.js";

const router = Router();

router.get("/", requireAuthentication, getNotificationsController);
router.patch("/:id/read", requireAuthentication, markNotificationAsReadController);
router.patch("/letters/:letterId/read", requireAuthentication, markLetterNotificationsAsReadController);

export default router;
