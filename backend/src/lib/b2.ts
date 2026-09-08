import { S3Client } from "@aws-sdk/client-s3";

const endpoint = process.env["B2_ENDPOINT"];
const region = process.env["B2_REGION"];
const accessKeyId = process.env["B2_KEY_ID"];
const secretAccessKey = process.env["B2_APPLICATION_KEY"];

if (!endpoint || !region || !accessKeyId || !secretAccessKey) {
  throw new Error("Missing Backblaze B2 environment variables");
}

export const b2 = new S3Client({
  endpoint,
  region,
  credentials: {
    accessKeyId,
    secretAccessKey,
  },
});