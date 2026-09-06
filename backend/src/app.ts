import express from "express";
import helloRouter from "./routes/hello.routes.js";
import statusRouter from "./routes/status.routes.js";
import testRouter from "./routes/test.routes.js";

const app = express();

app.use(express.json());

app.use((_request, _response, next) => {
  console.log("Request received");
  next();
});



app.use("/api", helloRouter);
app.use("/api", statusRouter);
app.use("/api", testRouter);
export default app;