import {
  claimLetter as claimLetterRepository,
  createLetter as createLetterRepository,
  findAvailableLetters,
  findSentLettersByUser,
  findClaimedLettersByArtist,
} from "./letter.repository.js";

import type { CreateLetterInput, PaginationInput } from "./letter.schema.js";

export class LetterNotAvailableError extends Error {
  constructor() {
    super("Letter is no longer available");
    this.name = "LetterNotAvailableError";
  }
}

export const createLetter = async (
  senderId: number,
  input: CreateLetterInput,
) => {
  return createLetterRepository(senderId, input);
};

export const claimLetter = async (letterId: number, artistId: number) => {
  const claimedAt = new Date();

  const result = await claimLetterRepository(letterId, artistId, claimedAt);

  const letter = result[0];

  if (!letter) {
    throw new LetterNotAvailableError();
  }

  return letter;
};

export const getAvailableLetters = async (pagination: PaginationInput) => {
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