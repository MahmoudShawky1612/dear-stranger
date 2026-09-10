import express, { Router } from "express";
import {
  optionalAuthentication,
  requireAuthentication,
} from "../../middleware/auth.middleware.js";
import {
  claimLetterController,
  completeArtworkDeliveryController,
  createArtworkUploadUrlController,
  uploadArtworkDirectController,
  createLetterController,
  createReplyController,
  getAvailableLettersController,
  getLetterController,
  getMySentLettersController,
  getMyClaimedLettersController,
  getArtworkAccessUrlController,
  publishArtworkController
} from "./letter.controller.js";

const router = Router();

router.get("/", optionalAuthentication, getAvailableLettersController);

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

// NOTE: /artwork/:artworkId/url must be before /:id to avoid the wildcard swallowing it
router.get(
  "/artwork/:artworkId/url",
  requireAuthentication,
  getArtworkAccessUrlController,
);

router.get("/:id", requireAuthentication, getLetterController);

router.post("/:id/claim", requireAuthentication, claimLetterController);

router.post(
  "/:id/artwork/upload-url",
  requireAuthentication,
  createArtworkUploadUrlController,
);

router.post(
  "/:id/artwork/file",
  requireAuthentication,
  express.raw({ type: () => true, limit: "10mb" }),
  uploadArtworkDirectController,
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

router.post(
  "/:id/artwork/publish",
  requireAuthentication,
  publishArtworkController,
);

export default router;