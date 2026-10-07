import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import authRouter from "./modules/auth/auth.routes.js";
import letterRouter from "./modules/letters/letter.routes.js";
import userRouter from "./modules/users/user.routes.js";
import notificationRouter from "./modules/notifications/notification.routes.js";
import { isAllowedOrigin } from "./lib/cors.js";
import { attachFrontend } from "./lib/frontend-static.js";

const app = express();

app.set("trust proxy", 1);

app.use(
  cors({
    origin: (origin, callback) => {
      if (isAllowedOrigin(origin)) {
        callback(null, true);
        return;
      }
      callback(null, false);
    },
    credentials: true,
  }),
);

app.use(express.json());
app.use(cookieParser());

app.get("/health", (_request, response) => {
  response.json({ ok: true });
});

app.use("/api/users", userRouter);
app.use("/api/auth", authRouter);
app.use("/api/letters", letterRouter);
app.use("/api/notifications", notificationRouter);

app.use("/api", (_request, response) => {
  response.status(404).json({ error: "Not found" });
});

attachFrontend(app);

export default app;
