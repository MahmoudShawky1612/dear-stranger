import express from "express";
import helloRouter from "./routes/hello.routes.js";
import statusRouter from "./routes/status.routes.js";

const app = express();

app.use("/api", helloRouter);
app.use("/api", statusRouter);

export default app;