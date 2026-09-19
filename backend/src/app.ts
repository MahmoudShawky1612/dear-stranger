import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import authRouter from "./modules/auth/auth.routes.js";
import letterRouter from "./modules/letters/letter.routes.js";
import userRouter from "./modules/users/user.routes.js";
import notificationRouter from "./modules/notifications/notification.routes.js";
import agentRouter from "./modules/agents/agent.routes.js";

const app = express();

const allowedOrigins = [
  /^http:\/\/localhost(:\d+)?$/,
  /^http:\/\/127\.0\.0\.1(:\d+)?$/,
];

app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin || allowedOrigins.some((re) => re.test(origin))) {
        callback(null, true);
      } else {
        callback(new Error(`CORS: origin ${origin} not allowed`));
      }
    },
    credentials: true,
  }),
);

app.use(express.json());
app.use(cookieParser());

app.use("/api/users", userRouter);
app.use("/api/auth", authRouter);
app.use("/api/letters", letterRouter);
app.use("/api/notifications", notificationRouter);
app.use("/api/agents", agentRouter);

export default app;
