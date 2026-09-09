import { getAvatarAccessUrl } from "./avatar.service.js";

type UserLike = {
  id: number;
  username: string;
  email?: string;
  displayName: string | null;
  bio: string | null;
  avatarUrl: string | null;
  location: string | null;
  favoriteMedium: string | null;
  currentlyDrawing: string | null;
  createdAt: Date;
};

export const serializeUser = async (
  user: UserLike,
  options?: { includeEmail?: boolean },
) => {
  const avatarUrl = await getAvatarAccessUrl(user.avatarUrl);

  return {
    id: user.id,
    username: user.username,
    ...(options?.includeEmail === true && user.email !== undefined
      ? { email: user.email }
      : {}),
    displayName: user.displayName,
    bio: user.bio,
    avatarUrl,
    location: user.location,
    favoriteMedium: user.favoriteMedium,
    currentlyDrawing: user.currentlyDrawing,
    createdAt: user.createdAt,
  };
};
