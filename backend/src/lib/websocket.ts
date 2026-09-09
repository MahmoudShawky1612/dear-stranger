import { WebSocketServer, WebSocket } from "ws";
import type { Server } from "node:http";
import { parse as parseCookie } from "cookie";
import { SESSION_COOKIE_NAME } from "../modules/auth/auth.cookie.js";
import { getSession } from "../modules/auth/auth.session.service.js";
import { findLetterById } from "../modules/letters/letter.repository.js";

type AuthenticatedSocket = WebSocket & {
  userId?: number;
  letterRooms?: Set<number>;
};

const letterRooms = new Map<number, Set<AuthenticatedSocket>>();

export const createWebSocketServer = (server: Server) => {
  const wss = new WebSocketServer({ server });

  wss.on("connection", async (socket: AuthenticatedSocket, request) => {
    socket.letterRooms = new Set();

    // --- Authenticate via session cookie ---
    const cookieHeader = request.headers.cookie;
    if (!cookieHeader) {
      socket.close(4001, "Authentication required");
      return;
    }

    const cookies = parseCookie(cookieHeader);
    const token = cookies[SESSION_COOKIE_NAME];

    if (!token) {
      socket.close(4001, "Authentication required");
      return;
    }

    try {
      const session = await getSession(token);
      if (!session) {
        socket.close(4001, "Invalid or expired session");
        return;
      }

      socket.userId = session.user.id;
    } catch {
      socket.close(4001, "Authentication failed");
      return;
    }

    // --- Handle messages from client ---
    socket.on("message", async (raw) => {
      let data: any;
      try {
        data = JSON.parse(raw.toString());
      } catch {
        return;
      }

      if (data.type === "join_letter") {
        const letterId = Number(data.letterId);
        if (!Number.isInteger(letterId) || letterId <= 0) return;

        const letter = await findLetterById(letterId);
        if (!letter) return;

        const isParticipant =
          letter.senderId === socket.userId ||
          letter.artistId === socket.userId;

        if (!isParticipant) return;

        // Join the room
        if (!letterRooms.has(letterId)) {
          letterRooms.set(letterId, new Set());
        }
        letterRooms.get(letterId)!.add(socket);
        socket.letterRooms!.add(letterId);

        socket.send(
          JSON.stringify({
            type: "joined_letter",
            letterId,
          }),
        );
      }

      if (data.type === "leave_letter") {
        const letterId = Number(data.letterId);
        leaveLetterRoom(socket, letterId);
      }
    });

    socket.on("close", () => {
      // Clean up all rooms this socket was in
      if (socket.letterRooms) {
        for (const letterId of socket.letterRooms) {
          leaveLetterRoom(socket, letterId);
        }
      }
    });
  });

  return wss;
};

const leaveLetterRoom = (socket: AuthenticatedSocket, letterId: number) => {
  const room = letterRooms.get(letterId);
  if (room) {
    room.delete(socket);
    if (room.size === 0) {
      letterRooms.delete(letterId);
    }
  }
  socket.letterRooms?.delete(letterId);
};

/** Call this whenever a new reply is created */
export const broadcastNewReply = (
  letterId: number,
  reply: {
    id: number;
    message: string;
    createdAt: Date;
    author: {
      id: number;
      username: string;
      displayName: string | null;
    };
  },
) => {
  const room = letterRooms.get(letterId);
  if (!room) return;

  const payload = JSON.stringify({
    type: "new_reply",
    letterId,
    reply: {
      id: reply.id,
      message: reply.message,
      createdAt: reply.createdAt,
      author: reply.author,
    },
  });

  for (const client of room) {
    if (client.readyState === WebSocket.OPEN) {
      client.send(payload);
    }
  }
};