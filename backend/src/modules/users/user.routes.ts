import { Router } from "express";
import { requireAuthentication } from "../../middleware/auth.middleware.js";
import {
  updateMyProfileController,
  getPublicProfileController,
  createGuestbookEntryController,
  getGuestbookEntriesController,
  deleteGuestbookEntryController,
  completeAvatarUploadController,
  createAvatarUploadUrlController,
  removeAvatarController,
} from "./user.controller.js";

const router = Router();

router.patch("/me", requireAuthentication, updateMyProfileController);

router.post(
  "/me/avatar/upload-url",
  requireAuthentication,
  createAvatarUploadUrlController,
);

router.post(
  "/me/avatar/complete",
  requireAuthentication,
  completeAvatarUploadController,
);

router.delete(
  "/me/avatar",
  requireAuthentication,
  removeAvatarController,
);

router.get("/:username/guestbook", getGuestbookEntriesController);
router.post(
  "/:username/guestbook",
  requireAuthentication,
  createGuestbookEntryController,
);

router.delete(
  "/guestbook/:id",
  requireAuthentication,
  deleteGuestbookEntryController,
);

router.get("/:username", getPublicProfileController);

export default router;