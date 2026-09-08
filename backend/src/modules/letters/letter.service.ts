import {
  claimLetter as claimLetterRepository,
  createLetter as createLetterRepository,
  findAvailableLetters,
} from "./letter.repository.js";

import type { CreateLetterInput } from "./letter.schema.js";

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

export const claimLetter = async (
  letterId: number,
  artistId: number,
) => {
  const claimedAt = new Date();

  const result = await claimLetterRepository(
    letterId,
    artistId,
    claimedAt,
  );

  const letter = result[0];

  if (!letter) {
    throw new LetterNotAvailableError();
  }

  return letter;
};

export const getAvailableLetters = async () => {
  return findAvailableLetters();
};