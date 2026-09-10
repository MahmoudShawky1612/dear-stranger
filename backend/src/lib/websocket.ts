import { WebSocketServer, WebSocket } from "ws";
import type { Server } from "node:http";
import { parse as parseCookie } from "cookie";
import { SESSION_COOKIE_NAME } from "../modules/auth/auth.cookie.js";
import { getSession } from "../modules/auth/auth.session.service.js";
import { findLetterById } from "../modules/letters/letter.repository.js";
import { getUnreadCount } from "../modules/notifications/notification.repository.js";

type AuthenticatedSocket = WebSocket & {
  userId?: number;
  letterRooms?: Set<number>;
};

const letterRooms = new Map<number, Set<AuthenticatedSocket>>();
const userSockets = new Map<number, Set<AuthenticatedSocket>>();

export const createWebSocketServer = (server: Server) => {
  const wss = new WebSocketServer({ server });

  wss.on("connection", (socket: AuthenticatedSocket, request) => {
    socket.letterRooms = new Set();

    // Authenticate in background, returning userId if valid
    const authPromise = (async (): Promise<number | null> => {
      const cookieHeader = request.headers.cookie;
      if (!cookieHeader) {
        socket.close(4001, "Authentication required");
        return null;
      }

      const cookies = parseCookie(cookieHeader);
      const token = cookies[SESSION_COOKIE_NAME];

      if (!token) {
        socket.close(4001, "Authentication required");
        return null;
      }

      try {
        const session = await getSession(token);
        if (!session) {
          socket.close(4001, "Invalid or expired session");
          return null;
        }

        socket.userId = Number(session.user.id);
        const uid = socket.userId;
        if (!userSockets.has(uid)) {
          userSockets.set(uid, new Set());
        }
        userSockets.get(uid)!.add(socket);

        getUnreadCount(uid).then((unreadCount) => {
          if (socket.readyState === WebSocket.OPEN) {
            socket.send(JSON.stringify({ type: "unread_count", unreadCount }));
          }
        }).catch(console.error);

        return uid;
      } catch {
        socket.close(4001, "Authentication failed");
        return null;
      }
    })();

    // --- Handle messages from client immediately so early messages are never dropped ---
    socket.on("message", async (raw) => {
      const userId = await authPromise;
      if (!userId) return;

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
          Number(letter.senderId) === Number(socket.userId) ||
          Number(letter.artistId) === Number(socket.userId);

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
      if (socket.userId) {
        const set = userSockets.get(socket.userId);
        if (set) {
          set.delete(socket);
          if (set.size === 0) {
            userSockets.delete(socket.userId);
          }
        }
      }

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

export const sendNotificationToUser = (
  userId: number,
  payload: {
    type: "notification" | "unread_count";
    notification?: {
      id: number;
      letterId: number;
      type: string;
      title: string;
      message: string;
      createdAt: Date;
    };
    unreadCount: number;
  },
) => {
  const sockets = userSockets.get(userId);
  if (!sockets) return;

  const json = JSON.stringify(payload);
  for (const client of sockets) {
    if (client.readyState === WebSocket.OPEN) {
      client.send(json);
    }
  }
};