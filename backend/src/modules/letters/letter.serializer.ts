type UserPreview = {
  id: number;
  username: string;
  displayName: string | null;
};

type ArtworkLike = {
  id: number;
  letterId: number;
  storageKey: string;
  contentType: string;
  fileSizeBytes: number;
  isAnonymous: boolean;
  isPublished: boolean;
  publishedAt: Date | null;
  createdAt: Date;
};

export const idsEqual = (a: unknown, b: unknown) =>
  a != null && b != null && Number(a) === Number(b);

export const serializeUserPreview = (user: UserPreview) => ({
  id: user.id,
  username: user.username,
  // Always a string so Dart clients that cast `as String` do not crash on null.
  displayName: user.displayName ?? "",
});

export const serializeArtwork = (artwork: ArtworkLike) => ({
  id: artwork.id,
  letterId: artwork.letterId,
  storageKey: artwork.storageKey,
  contentType: artwork.contentType,
  fileSizeBytes: artwork.fileSizeBytes,
  isAnonymous: artwork.isAnonymous,
  isPublished: artwork.isPublished,
  publishedAt: artwork.publishedAt,
  createdAt: artwork.createdAt,
});
