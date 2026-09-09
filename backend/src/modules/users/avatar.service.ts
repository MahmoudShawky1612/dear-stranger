import {
  DeleteObjectCommand,
  GetObjectCommand,
  HeadObjectCommand,
  PutObjectCommand,
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { randomUUID } from "node:crypto";

import { avatarBucketName, b2Avatars } from "../../lib/b2.js";
import {
  findUserById,
  findUserByUsername,
  updateUserAvatar,
} from "./user.repository.js";
import type {
  CompleteAvatarInput,
  CreateAvatarUploadInput,
} from "./avatar.schema.js";
import { UserNotFoundError } from "./user.service.js";

const UPLOAD_URL_TTL_SECONDS = 10 * 60;
const AVATAR_URL_TTL_SECONDS = 6 * 24 * 60 * 60;
const MAX_AVATAR_SIZE_BYTES = 2 * 1024 * 1024;

const extensionByContentType: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
};

const allowedContentTypes = new Set(Object.keys(extensionByContentType));

export class AvatarUploadValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "AvatarUploadValidationError";
  }
}

export class AvatarNotFoundError extends Error {
  constructor() {
    super("Avatar not found");
    this.name = "AvatarNotFoundError";
  }
}

export const extractAvatarStorageKey = (
  stored: string | null | undefined,
): string | null => {
  if (!stored) {
    return null;
  }

  if (stored.startsWith("avatars/")) {
    return stored;
  }

  try {
    const url = new URL(stored);
    const key = url.pathname.replace(/^\/+/, "");
    if (key.startsWith("avatars/")) {
      return key;
    }
  } catch {
    // not a URL
  }

  const fromHost = stored.split(".com/")[1];
  if (fromHost?.startsWith("avatars/")) {
    return fromHost;
  }

  return null;
};

export const getAvatarAccessUrl = async (
  stored: string | null | undefined,
): Promise<string | null> => {
  const storageKey = extractAvatarStorageKey(stored);

  if (!storageKey) {
    return stored ?? null;
  }

  const command = new GetObjectCommand({
    Bucket: avatarBucketName,
    Key: storageKey,
  });

  return getSignedUrl(b2Avatars, command, {
    expiresIn: AVATAR_URL_TTL_SECONDS,
  });
};

const deleteAvatarObject = async (storageKey: string) => {
  try {
    await b2Avatars.send(
      new DeleteObjectCommand({
        Bucket: avatarBucketName,
        Key: storageKey,
      }),
    );
  } catch {
    // ignore cleanup errors
  }
};

export const createAvatarUploadUrl = async (
  userId: number,
  input: CreateAvatarUploadInput,
) => {
  const user = await findUserById(userId);
  if (!user) {
    throw new UserNotFoundError();
  }

  if (input.fileSizeBytes > MAX_AVATAR_SIZE_BYTES) {
    throw new AvatarUploadValidationError("Avatar must be 2 MB or smaller");
  }

  const extension = extensionByContentType[input.contentType];
  const storageKey = `avatars/${userId}/${randomUUID()}.${extension}`;

  const command = new PutObjectCommand({
    Bucket: avatarBucketName,
    Key: storageKey,
    ContentType: input.contentType,
  });

  const uploadUrl = await getSignedUrl(b2Avatars, command, {
    expiresIn: UPLOAD_URL_TTL_SECONDS,
  });

  return {
    uploadUrl,
    storageKey,
    expiresIn: UPLOAD_URL_TTL_SECONDS,
  };
};

export const completeAvatarUpload = async (
  userId: number,
  input: CompleteAvatarInput,
) => {
  const user = await findUserById(userId);
  if (!user) {
    throw new UserNotFoundError();
  }

  const expectedPrefix = `avatars/${userId}/`;
  if (!input.storageKey.startsWith(expectedPrefix)) {
    throw new AvatarUploadValidationError("Avatar does not belong to this user");
  }

  let metadata;
  try {
    const result = await b2Avatars.send(
      new HeadObjectCommand({
        Bucket: avatarBucketName,
        Key: input.storageKey,
      }),
    );
    metadata = {
      contentType: result.ContentType ?? null,
      fileSizeBytes: result.ContentLength ?? null,
    };
  } catch {
    throw new AvatarUploadValidationError("Uploaded avatar was not found");
  }

  if (
    !metadata.contentType ||
    !allowedContentTypes.has(metadata.contentType)
  ) {
    throw new AvatarUploadValidationError("Invalid avatar content type");
  }

  if (
    metadata.fileSizeBytes === null ||
    metadata.fileSizeBytes <= 0 ||
    metadata.fileSizeBytes > MAX_AVATAR_SIZE_BYTES
  ) {
    throw new AvatarUploadValidationError("Invalid avatar file size");
  }

  const oldKey = extractAvatarStorageKey(user.avatarUrl);
  if (oldKey && oldKey !== input.storageKey && oldKey.startsWith(expectedPrefix)) {
    await deleteAvatarObject(oldKey);
  }

  const updatedUser = await updateUserAvatar(userId, input.storageKey);
  const avatarUrl = await getAvatarAccessUrl(updatedUser.avatarUrl);

  return {
    ...updatedUser,
    avatarUrl,
  };
};

export const removeAvatar = async (userId: number) => {
  const user = await findUserById(userId);
  if (!user) {
    throw new UserNotFoundError();
  }

  const key = extractAvatarStorageKey(user.avatarUrl);
  if (key?.startsWith(`avatars/${userId}/`)) {
    await deleteAvatarObject(key);
  }

  const updatedUser = await updateUserAvatar(userId, null);

  return {
    ...updatedUser,
    avatarUrl: null,
  };
};

export const getPublicAvatarAccessUrl = async (username: string) => {
  const user = await findUserByUsername(username);

  if (!user) {
    throw new UserNotFoundError();
  }

  const url = await getAvatarAccessUrl(user.avatarUrl);

  if (!url) {
    throw new AvatarNotFoundError();
  }

  return {
    url,
    expiresIn: AVATAR_URL_TTL_SECONDS,
  };
};
