import { Router } from "express";
import { requireAuthentication } from "../../middleware/auth.middleware.js";
import {
  updateMyProfileController,
  getPublicProfileController,
} from "./user.controller.js";

const router = Router();

router.patch("/me", requireAuthentication, updateMyProfileController);

router.get("/:username", getPublicProfileController);

export default router;