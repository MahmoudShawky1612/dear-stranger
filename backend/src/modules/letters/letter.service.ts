import {
  claimLetter as claimLetterRepository,
  createLetter as createLetterRepository,
  findAvailableLetters,
  findSentLettersByUser,
  findClaimedLettersByArtist,
  findLetterById,
} from "./letter.repository.js";
import { createAndDispatchNotification } from "../notifications/notification.service.js";

import type { CreateLetterInput, PaginationInput } from "./letter.schema.js";

export class LetterNotAvailableError extends Error {
  constructor() {
    super("Letter is no longer available");
    this.name = "LetterNotAvailableError";
  }
}

export class CannotClaimOwnLetterError extends Error {
  constructor() {
    super("You cannot claim your own letter");
    this.name = "CannotClaimOwnLetterError";
  }
}

export const createLetter = async (
  senderId: number,
  input: CreateLetterInput,
) => {
  return createLetterRepository(senderId, input);
};

export const claimLetter = async (letterId: number, artistId: number) => {
  const existing = await findLetterById(letterId);

  if (!existing) {
    throw new LetterNotAvailableError();
  }

  if (Number(existing.senderId) === Number(artistId)) {
    throw new CannotClaimOwnLetterError();
  }

  if (existing.status !== "AVAILABLE" || existing.artistId !== null) {
    throw new LetterNotAvailableError();
  }

  const claimedAt = new Date();

  const result = await claimLetterRepository(letterId, artistId, claimedAt);

  const letter = result[0];

  if (!letter) {
    throw new LetterNotAvailableError();
  }

  createAndDispatchNotification({
    userId: Number(existing.senderId),
    letterId,
    type: "LETTER_CLAIMED",
    title: "💌 Letter Claimed!",
    message: `An artist has claimed your letter "${existing.title}"!`,
  }).catch(console.error);

  return letter;
};

export const getAvailableLetters = async (
  pagination: PaginationInput,
) => {
  const params: { limit: number; cursor?: number } = {
    limit: pagination.limit,
  };

  if (pagination.cursor !== undefined) {
    params.cursor = pagination.cursor;
  }

  const letters = await findAvailableLetters(params);

  const nextCursor =
    letters.length === pagination.limit
      ? (letters[letters.length - 1]?.id ?? null)
      : null;

  return { letters, nextCursor };
};

export const getMySentLetters = async (
  userId: number,
  pagination: PaginationInput,
) => {
  const params: { limit: number; cursor?: number } = {
    limit: pagination.limit,
  };

  if (pagination.cursor !== undefined) {
    params.cursor = pagination.cursor;
  }

  const letters = await findSentLettersByUser(userId, params);

  const nextCursor =
    letters.length === pagination.limit
      ? (letters[letters.length - 1]?.id ?? null)
      : null;

  return { letters, nextCursor };
};

export const getMyClaimedLetters = async (
  userId: number,
  pagination: PaginationInput,
) => {
  const params: { limit: number; cursor?: number } = {
    limit: pagination.limit,
  };

  if (pagination.cursor !== undefined) {
    params.cursor = pagination.cursor;
  }

  const letters = await findClaimedLettersByArtist(userId, params);

  const nextCursor =
    letters.length === pagination.limit
      ? (letters[letters.length - 1]?.id ?? null)
      : null;

  return { letters, nextCursor };
};