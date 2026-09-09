import {
  findUserById,
  updateUserProfile as updateUserProfileRepository,
  findPublicUserByUsername,
} from "./user.repository.js";
import type { UpdateProfileInput } from "./user.schema.js";

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