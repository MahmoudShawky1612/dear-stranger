import { Router } from "express";
import {
  getCurrentUserController,
  loginController,
  logoutController,
  registerController,
} from "./auth.controller.js";
import { requireAuthentication } from "../../middleware/auth.middleware.js";
import { authRateLimiter } from "./auth.rate-limit.js";

const router = Router();

router.post("/register", authRateLimiter, registerController);

router.post("/login", authRateLimiter, loginController);

router.get("/me", requireAuthentication, getCurrentUserController);

router.post("/logout", logoutController);

export default router;