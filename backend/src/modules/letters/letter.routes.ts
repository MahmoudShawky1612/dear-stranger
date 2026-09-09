import { Router } from "express";
import { requireAuthentication } from "../../middleware/auth.middleware.js";
import {
  claimLetterController,
  completeArtworkDeliveryController,
  createArtworkUploadUrlController,
  createLetterController,
  createReplyController,
  getAvailableLettersController,
  getLetterController,
  getMySentLettersController,
  getMyClaimedLettersController,
} from "./letter.controller.js";

const router = Router();

router.get("/", getAvailableLettersController);

router.get(
  "/mine/sent",
  requireAuthentication,
  getMySentLettersController,
);

router.get(
  "/mine/claimed",
  requireAuthentication,
  getMyClaimedLettersController,
);

router.post("/", requireAuthentication, createLetterController);

router.get("/:id", requireAuthentication, getLetterController);

router.post("/:id/claim", requireAuthentication, claimLetterController);

router.post(
  "/:id/artwork/upload-url",
  requireAuthentication,
  createArtworkUploadUrlController,
);

router.post(
  "/:id/artwork/complete",
  requireAuthentication,
  completeArtworkDeliveryController,
);

router.post(
  "/:id/replies",
  requireAuthentication,
  createReplyController,
);

export default router;