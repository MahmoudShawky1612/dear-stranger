import {
  HeadObjectCommand,
  PutObjectCommand,
  DeleteObjectCommand,
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { randomUUID } from "node:crypto";
import { b2 } from "../../lib/b2.js";
import {
  findUserById,
  updateUserAvatar,
} from "./user.repository.js";
import type {
  CreateAvatarUploadInput,
  CompleteAvatarInput,
} from "./avatar.schema.js";
import { UserNotFoundError } from "./user.service.js";

const bucketName = process.env["B2_BUCKET_NAME"];
if (!bucketName) {
  throw new Error("Missing B2_BUCKET_NAME environment variable");
}

const UPLOAD_URL_TTL_SECONDS = 10 * 60;
const MAX_AVATAR_SIZE_BYTES = 2 * 1024 * 1024;

const extensionByContentType: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
};

export class AvatarUploadValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "AvatarUploadValidationError";
  }
}

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
    Bucket: bucketName,
    Key: storageKey,
    ContentType: input.contentType,
  });

  const uploadUrl = await getSignedUrl(b2, command, {
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

  // Verify the real object in B2
  let metadata;
  try {
    const result = await b2.send(
      new HeadObjectCommand({
        Bucket: bucketName,
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

  if (!metadata.contentType || !["image/jpeg", "image/png", "image/webp"].includes(metadata.contentType)) {
    throw new AvatarUploadValidationError("Invalid avatar content type");
  }

  if (
    metadata.fileSizeBytes === null ||
    metadata.fileSizeBytes <= 0 ||
    metadata.fileSizeBytes > MAX_AVATAR_SIZE_BYTES
  ) {
    throw new AvatarUploadValidationError("Invalid avatar file size");
  }

  // Optional: delete old avatar from B2 if it exists
  if (user.avatarUrl) {
    const oldKey = user.avatarUrl.split(".com/")[1]; // adjust if your public URL format is different
    if (oldKey && oldKey.startsWith(`avatars/${userId}/`)) {
      try {
        await b2.send(
          new DeleteObjectCommand({
            Bucket: bucketName,
            Key: oldKey,
          }),
        );
      } catch {
        // ignore cleanup errors
      }
    }
  }

  // Build the public URL (adjust to your B2 public URL style)
  const publicBase = process.env["B2_PUBLIC_URL"]; // e.g. https://f000.backblazeb2.com/file/your-bucket
  if (!publicBase) {
    throw new Error("Missing B2_PUBLIC_URL environment variable");
  }

  const avatarUrl = `${publicBase}/${input.storageKey}`;

  const updatedUser = await updateUserAvatar(userId, avatarUrl);

  return updatedUser;
};

export const removeAvatar = async (userId: number) => {
  const user = await findUserById(userId);
  if (!user) {
    throw new UserNotFoundError();
  }

  if (user.avatarUrl) {
    // Best-effort delete from B2
    const key = user.avatarUrl.replace(/^https?:\/\/[^/]+\//, "");
    if (key.startsWith(`avatars/${userId}/`)) {
      try {
        await b2.send(
          new DeleteObjectCommand({
            Bucket: bucketName,
            Key: key,
          }),
        );
      } catch {
        // ignore
      }
    }
  }

  return updateUserAvatar(userId, null);
};