import "dotenv/config";
import http from "node:http";
import app from "./app.js";
import { createWebSocketServer } from "./lib/websocket.js";
import { ensureBucketCors } from "./lib/b2.js";
import { startClaimTimeoutScheduler } from "./modules/letters/letter.timeout.service.js";

const PORT = 3000;

const server = http.createServer(app);

createWebSocketServer(server);

ensureBucketCors().catch(console.error);

// Start the 72-hour claim auto-release background scheduler
startClaimTimeoutScheduler(30);

server.listen(PORT, () => {
  console.log(`Dear Stranger server is running on port ${PORT}`);
  console.log(`WebSocket ready on ws://localhost:${PORT}`);
});
