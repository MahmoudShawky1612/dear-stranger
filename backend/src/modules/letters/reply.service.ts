import {
  createReply as createReplyRepository,
  findLetterById,
} from "./letter.repository.js";
import type { CreateReplyInput } from "./reply.schema.js";
import { broadcastNewReply } from "../../lib/websocket.js";
import { createAndDispatchNotification } from "../notifications/notification.service.js";

export class LetterNotFoundError extends Error {
  constructor() {
    super("Letter not found");
    this.name = "LetterNotFoundError";
  }
}

export class LetterNotDeliveredError extends Error {
  constructor() {
    super("Replies are only allowed after the letter has been delivered");
    this.name = "LetterNotDeliveredError";
  }
}

export class NotParticipantError extends Error {
  constructor() {
    super("Only the sender or the artist of this letter can reply");
    this.name = "NotParticipantError";
  }
}

export const getLetterById = async (letterId: number, userId: number) => {
  const letter = await findLetterById(letterId);

  if (!letter) {
    throw new LetterNotFoundError();
  }

  // Anyone can view an available letter to decide whether to claim it
  if (letter.status === "AVAILABLE") {
    return letter;
  }

  // Only the sender or the artist can view claimed or delivered letters
  const isSender = Number(letter.senderId) === Number(userId);
  const isArtist = Number(letter.artistId) === Number(userId);

  if (!isSender && !isArtist) {
    throw new NotParticipantError();
  }

  return letter;
};

export const createReply = async (
  letterId: number,
  authorId: number,
  input: CreateReplyInput,
) => {
  const letter = await findLetterById(letterId);

  if (!letter) {
    throw new LetterNotFoundError();
  }

  if (letter.status !== "DELIVERED") {
    throw new LetterNotDeliveredError();
  }

  const isSender = Number(letter.senderId) === Number(authorId);
  const isArtist = Number(letter.artistId) === Number(authorId);

  if (!isSender && !isArtist) {
    throw new NotParticipantError();
  }

const reply = await createReplyRepository({
  letterId,
  authorId,
  message: input.message,
});

broadcastNewReply(letterId, {
  id: reply.id,
  message: reply.message,
  createdAt: reply.createdAt,
  author: {
    id: reply.author.id,
    username: reply.author.username,
    displayName: reply.author.displayName,
  },
});

const recipientId = isSender ? Number(letter.artistId) : Number(letter.senderId);
const authorName = reply.author.displayName || reply.author.username;
createAndDispatchNotification({
  userId: recipientId,
  letterId,
  type: "NEW_REPLY",
  title: `New reply from ${authorName}`,
  message: reply.message.length > 80 ? reply.message.slice(0, 77) + "..." : reply.message,
}).catch(console.error);

return reply;
};