import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import authRouter from "./modules/auth/auth.routes.js";
import letterRouter from "./modules/letters/letter.routes.js";
import userRouter from "./modules/users/user.routes.js";
import notificationRouter from "./modules/notifications/notification.routes.js";

const app = express();

// Allow Flutter web dev server (any localhost port) + future production origin
const allowedOrigins = [
  /^http:\/\/localhost(:\d+)?$/,
  /^http:\/\/127\.0\.0\.1(:\d+)?$/,
];

app.use(
  cors({
    origin: (origin, callback) => {
      // Allow no-origin requests (curl, Postman) and matched origins
      if (!origin || allowedOrigins.some((re) => re.test(origin))) {
        callback(null, true);
      } else {
        callback(new Error(`CORS: origin ${origin} not allowed`));
      }
    },
    credentials: true, // needed so cookies are sent back
  }),
);

app.use(express.json());
app.use(cookieParser());

app.use("/api/users", userRouter);
app.use("/api/auth", authRouter);
app.use("/api/letters", letterRouter);
app.use("/api/notifications", notificationRouter);

export default app;