import {
  createGuestbookEntry as createGuestbookEntryRepository,  
  deleteGuestbookEntry as deleteGuestbookEntryRepository,
  findUserById,
  updateUserProfile as updateUserProfileRepository,
  findPublicUserByUsername,
  findGuestbookEntryById,
  findGuestbookEntries,
  searchUsersByUsername,
  findPublishedArtworksByArtistId,
} from "./user.repository.js";
import type { UpdateProfileInput, SearchUsersInput } from "./user.schema.js";
import type { CreateGuestbookEntryInput } from "./guestbook.schema.js";
import type { PaginationInput } from "../letters/letter.schema.js";
import { signArtworkStorageKey } from "../letters/artwork.access.service.js";

export class GuestbookEntryNotFoundError extends Error {
  constructor() {
    super("Guestbook entry not found");
    this.name = "GuestbookEntryNotFoundError";
  }
}

export class NotAllowedError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "NotAllowedError";
  }
}
export class UserNotFoundError extends Error {
  constructor() {
    super("User not found");
    this.name = "UserNotFoundError";
  }
}

export const getUserById = async (userId: number) => {
  return findUserById(userId);
};

export const updateMyProfile = async (
  userId: number,
  input: UpdateProfileInput,
) => {
  const user = await findUserById(userId);

  if (!user) {
    throw new UserNotFoundError();
  }

  // Strip undefined so exactOptionalPropertyTypes is happy
  const cleanInput: {
    displayName?: string | null;
    bio?: string | null;
    location?: string | null;
    favoriteMedium?: string | null;
    currentlyDrawing?: string | null;
  } = {};

  if (input.displayName !== undefined) cleanInput.displayName = input.displayName;
  if (input.bio !== undefined) cleanInput.bio = input.bio;
  if (input.location !== undefined) cleanInput.location = input.location;
  if (input.favoriteMedium !== undefined) cleanInput.favoriteMedium = input.favoriteMedium;
  if (input.currentlyDrawing !== undefined) cleanInput.currentlyDrawing = input.currentlyDrawing;

  return updateUserProfileRepository(userId, cleanInput);
};

export const getPublicProfileByUsername = async (username: string) => {
  const user = await findPublicUserByUsername(username);

  if (!user) {
    throw new UserNotFoundError();
  }

  return user;
};

export const searchUsers = async (input: SearchUsersInput) => {
  const query = input.q.replace(/^@+/, "").trim();
  if (!query) {
    return [];
  }

  return searchUsersByUsername(query, input.limit);
};

export const getPublishedGallery = async (
  username: string,
  pagination: PaginationInput,
) => {
  const host = await findPublicUserByUsername(username);

  if (!host) {
    throw new UserNotFoundError();
  }

  const params: { limit: number; cursor?: number } = {
    limit: pagination.limit,
  };

  if (pagination.cursor !== undefined) {
    params.cursor = pagination.cursor;
  }

  const artworks = await findPublishedArtworksByArtistId(host.id, params);

  const items = await Promise.all(
    artworks.map(async (artwork) => {
      const signed = await signArtworkStorageKey(artwork.storageKey);
      return {
        id: artwork.id,
        letterId: artwork.letterId,
        letterTitle: artwork.letter.title,
        url: signed.url,
        publishedAt: artwork.publishedAt,
        createdAt: artwork.createdAt,
      };
    }),
  );

  const nextCursor =
    artworks.length === pagination.limit
      ? (artworks[artworks.length - 1]?.id ?? null)
      : null;

  return { items, nextCursor };
};

export const createGuestbookEntry = async (
  hostUsername: string,
  authorId: number,
  input: CreateGuestbookEntryInput,
) => {
  const host = await findPublicUserByUsername(hostUsername);

  if (!host) {
    throw new UserNotFoundError();
  }

  if (host.id === authorId) {
    throw new NotAllowedError("You cannot write in your own guestbook");
  }

  return createGuestbookEntryRepository({
    hostId: host.id,
    authorId,
    message: input.message,
  });
};

export const getGuestbookEntries = async (
  hostUsername: string,
  pagination: PaginationInput,
) => {
  const host = await findPublicUserByUsername(hostUsername);

  if (!host) {
    throw new UserNotFoundError();
  }

  const params: { limit: number; cursor?: number } = {
    limit: pagination.limit,
  };

  if (pagination.cursor !== undefined) {
    params.cursor = pagination.cursor;
  }

  const entries = await findGuestbookEntries(host.id, params);

  const nextCursor =
    entries.length === pagination.limit
      ? (entries[entries.length - 1]?.id ?? null)
      : null;

  return { entries, nextCursor };
};

export const deleteGuestbookEntry = async (
  entryId: number,
  userId: number,
) => {
  const entry = await findGuestbookEntryById(entryId);

  if (!entry) {
    throw new GuestbookEntryNotFoundError();
  }

  // Only the author or the host can delete
  if (entry.authorId !== userId && entry.hostId !== userId) {
    throw new NotAllowedError("You cannot delete this entry");
  }

  await deleteGuestbookEntryRepository(entryId);
};