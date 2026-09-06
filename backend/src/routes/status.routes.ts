import { Router } from "express";

const router = Router();

router.get("/status", (_request, response) => {
  response.json({
    status: "online",
  });
});

export default router;