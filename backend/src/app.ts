import express from "express";
import cookieParser from "cookie-parser";
import authRouter from "./modules/auth/auth.routes.js";
import letterRouter from "./modules/letters/letter.routes.js";

const app = express();

app.use(express.json());
app.use(cookieParser());

app.use("/api/auth", authRouter);
app.use("/api/letters", letterRouter);

app.use((_request, _response, next) => {
  console.log("Request received");
  next();
});



export default app;