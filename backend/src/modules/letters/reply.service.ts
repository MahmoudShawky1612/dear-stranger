import {
  createReply as createReplyRepository,
  findLetterById,
} from "./letter.repository.js";
import type { CreateReplyInput } from "./reply.schema.js";
import { broadcastNewReply } from "../../lib/websocket.js";

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

  // Only the sender or the artist can view the full thread
  const isSender = letter.senderId === userId;
  const isArtist = letter.artistId === userId;

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

  const isSender = letter.senderId === authorId;
  const isArtist = letter.artistId === authorId;

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

return reply;
};