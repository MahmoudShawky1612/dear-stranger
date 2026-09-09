import { S3Client } from "@aws-sdk/client-s3";

const endpoint = process.env["B2_ENDPOINT"];
const region = process.env["B2_REGION"];
const accessKeyId = process.env["B2_KEY_ID"];
const secretAccessKey = process.env["B2_APPLICATION_KEY"];

if (!endpoint || !region || !accessKeyId || !secretAccessKey) {
  throw new Error("Missing Backblaze B2 environment variables");
}

const sharedConfig = {
  endpoint,
  region,
  // AWS SDK v3 signs checksum headers by default; B2 presigned PUTs fail without this.
  requestChecksumCalculation: "WHEN_REQUIRED" as const,
  responseChecksumValidation: "WHEN_REQUIRED" as const,
};

export const b2 = new S3Client({
  ...sharedConfig,
  credentials: {
    accessKeyId,
    secretAccessKey,
  },
});

const avatarAccessKeyId =
  process.env["B2_AVATAR_KEY_ID"] ?? accessKeyId;
const avatarSecretAccessKey =
  process.env["B2_AVATAR_APPLICATION_KEY"] ?? secretAccessKey;

export const b2Avatars =
  avatarAccessKeyId === accessKeyId &&
  avatarSecretAccessKey === secretAccessKey
    ? b2
    : new S3Client({
        ...sharedConfig,
        credentials: {
          accessKeyId: avatarAccessKeyId,
          secretAccessKey: avatarSecretAccessKey,
        },
      });

export const artworkBucketName = process.env["B2_BUCKET_NAME"];
export const avatarBucketName =
  process.env["B2_AVATAR_BUCKET_NAME"] ?? artworkBucketName;

if (!artworkBucketName) {
  throw new Error("Missing B2_BUCKET_NAME environment variable");
}

if (!avatarBucketName) {
  throw new Error("Missing B2_AVATAR_BUCKET_NAME environment variable");
}
