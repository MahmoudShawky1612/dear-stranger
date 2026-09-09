import "dotenv/config";
import http from "node:http";
import app from "./app.js";
import { createWebSocketServer } from "./lib/websocket.js";

const PORT = 3000;

const server = http.createServer(app);

createWebSocketServer(server);

server.listen(PORT, () => {
  console.log(`Dear Stranger server is running on port ${PORT}`);
  console.log(`WebSocket ready on ws://localhost:${PORT}`);
});