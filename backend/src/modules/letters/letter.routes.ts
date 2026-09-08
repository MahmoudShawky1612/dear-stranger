import { Router } from "express";
import { requireAuthentication } from "../../middleware/auth.middleware.js";
import {
  claimLetterController,
  completeArtworkDeliveryController,
  createArtworkUploadUrlController,
  createLetterController,
  getAvailableLettersController,
} from "./letter.controller.js";
const router = Router();

router.get(
  "/",
  getAvailableLettersController,
);

router.post(
  "/",
  requireAuthentication,
  createLetterController,
);

router.post(
  "/:id/claim",
  requireAuthentication,
  claimLetterController,
);

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

export default router;