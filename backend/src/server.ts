import "dotenv/config";
import http from "node:http";
import app from "./app.js";
import { createWebSocketServer } from "./lib/websocket.js";
import { ensureBucketCors } from "./lib/b2.js";
import { startClaimTimeoutScheduler } from "./modules/letters/letter.timeout.service.js";

const PORT = Number(process.env["PORT"]) || 3000;

const server = http.createServer(app);

createWebSocketServer(server);

ensureBucketCors().catch(console.error);


