import {
  HeadObjectCommand,
  PutObjectCommand,
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { randomUUID } from "node:crypto";

import { b2 } from "../../lib/b2.js";
import type { CreateArtworkUploadInput } from "./artwork.schema.js";

import {
  createArtworkAndDeliverLetter,
  findArtworkByLetterId,
} from "./letter.repository.js";

import {
  completeArtworkDelivery as completeArtworkDeliveryRepository,
  createArtworkUpload,
  deleteArtworkUpload,
  findArtworkUpload,
  findClaimedLetterForArtist,
  findLetterById,
} from "./letter.repository.js";
import { createAndDispatchNotification } from "../notifications/notification.service.js";

export class ArtworkAlreadyDeliveredError extends Error {
  constructor() {
    super("This Letter already has a delivered artwork");
    this.name = "ArtworkAlreadyDeliveredError";
  }
}

export class UploadedArtworkNotFoundError extends Error {
  constructor() {
    super("Uploaded artwork could not be found");
    this.name = "UploadedArtworkNotFoundError";
  }
}

export class InvalidArtworkError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "InvalidArtworkError";
  }
}

const bucketName = process.env["B2_BUCKET_NAME"];

if (!bucketName) {
  throw new Error("Missing B2_BUCKET_NAME environment variable");
}

const UPLOAD_URL_TTL_SECONDS = 10 * 60;
const MAX_ARTWORK_SIZE_BYTES = 10 * 1024 * 1024;

const extensionByContentType: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
};

export class LetterNotClaimedByArtistError extends Error {
  constructor() {
    super("You can only upload artwork for a Letter you have claimed");
    this.name = "LetterNotClaimedByArtistError";
  }
}

export class ArtworkUploadValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ArtworkUploadValidationError";
  }
}

export const createArtworkUploadUrl = async (
  letterId: number,
  artistId: number,
  input: CreateArtworkUploadInput,
) => {
  const letter = await findClaimedLetterForArtist(letterId, artistId);

  if (!letter) {
    throw new LetterNotClaimedByArtistError();
  }

  if (input.fileSizeBytes > MAX_ARTWORK_SIZE_BYTES) {
    throw new ArtworkUploadValidationError(
      "Artwork must be 10 MB or smaller",
    );
  }

  const extension = extensionByContentType[input.contentType];
  if (!extension) {
    throw new ArtworkUploadValidationError(
      "Only JPEG, PNG, and WebP images are supported",
    );
  }

  const storageKey = `artworks/${letterId}/${randomUUID()}.${extension}`;

  const expiresAt = new Date(
    Date.now() + UPLOAD_URL_TTL_SECONDS * 1000,
  );

  await createArtworkUpload({
    letterId,
    artistId,
    storageKey,
    contentType: input.contentType,
    expectedSize: input.fileSizeBytes,
    expiresAt,
  });

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

export const uploadArtworkDirect = async (
  letterId: number,
  artistId: number,
  input: {
    contentType: CreateArtworkUploadInput["contentType"];
    body: Buffer;
    isAnonymous: boolean;
  },
) => {
  const { storageKey } = await createArtworkUploadUrl(letterId, artistId, {
    contentType: input.contentType,
    fileSizeBytes: input.body.length,
  });

  await b2.send(
    new PutObjectCommand({
      Bucket: bucketName,
      Key: storageKey,
      ContentType: input.contentType,
      Body: input.body,
      ContentLength: input.body.length,
    }),
  );

  return completeArtworkDelivery(letterId, artistId, {
    storageKey,
    isAnonymous: input.isAnonymous,
  });
};

export const getUploadedArtworkMetadata = async (
  storageKey: string,
) => {
  try {
    const result = await b2.send(
      new HeadObjectCommand({
        Bucket: bucketName,
        Key: storageKey,
      }),
    );

    return {
      contentType: result.ContentType ?? null,
      fileSizeBytes: result.ContentLength ?? null,
    };
  } catch {
    return null;
  }
};

export const prepareArtworkDelivery = async (
  letterId: number,
  artistId: number,
  storageKey: string,
  isAnonymous: boolean,
) => {
  const letter = await findClaimedLetterForArtist(letterId, artistId);

  if (!letter) {
    throw new LetterNotClaimedByArtistError();
  }

  const existingArtwork = await findArtworkByLetterId(letterId);

  if (existingArtwork) {
    throw new ArtworkAlreadyDeliveredError();
  }

  const expectedPrefix = `artworks/${letterId}/`;

  if (!storageKey.startsWith(expectedPrefix)) {
    throw new InvalidArtworkError(
      "Artwork does not belong to this Letter",
    );
  }

  return {
    storageKey,
    isAnonymous,
  };
};

export const verifyUploadedArtwork = async (
  storageKey: string,
  expectedContentType: string,
  expectedFileSizeBytes: number,
) => {
  const metadata = await getUploadedArtworkMetadata(storageKey);

  if (!metadata) {
    throw new ArtworkUploadValidationError(
      "Uploaded artwork was not found",
    );
  }

  if (metadata.contentType !== expectedContentType) {
    throw new ArtworkUploadValidationError(
      "Uploaded artwork content type does not match",
    );
  }

  if (
    metadata.fileSizeBytes === null ||
    metadata.fileSizeBytes <= 0 ||
    metadata.fileSizeBytes > MAX_ARTWORK_SIZE_BYTES
  ) {
    throw new ArtworkUploadValidationError(
      "Uploaded artwork has an invalid file size",
    );
  }

  if (metadata.fileSizeBytes !== expectedFileSizeBytes) {
    throw new ArtworkUploadValidationError(
      "Uploaded artwork file size does not match",
    );
  }

  return metadata;
};

export const completeArtworkDelivery = async (
  letterId: number,
  artistId: number,
  input: {
    storageKey: string;
    isAnonymous: boolean;
  },
) => {
  const upload = await findArtworkUpload(
    letterId,
    artistId,
    input.storageKey,
  );

  if (!upload) {
    throw new ArtworkUploadValidationError(
      "Upload authorization could not be found",
    );
  }

  if (
    upload.letterId !== letterId ||
    upload.artistId !== artistId
  ) {
    throw new ArtworkUploadValidationError(
      "Upload authorization does not belong to this Letter",
    );
  }

  if (upload.expiresAt <= new Date()) {
    throw new ArtworkUploadValidationError(
      "Upload authorization has expired",
    );
  }

  if (!input.storageKey.startsWith(`artworks/${letterId}/`)) {
    throw new ArtworkUploadValidationError(
      "Artwork does not belong to this Letter",
    );
  }

  const metadata = await getUploadedArtworkMetadata(
    upload.storageKey,
  );

  if (!metadata) {
    throw new ArtworkUploadValidationError(
      "Uploaded artwork was not found",
    );
  }

  if (metadata.contentType !== upload.contentType) {
    throw new ArtworkUploadValidationError(
      "Uploaded artwork content type does not match the authorized upload",
    );
  }

  if (
    metadata.fileSizeBytes === null ||
    metadata.fileSizeBytes <= 0 ||
    metadata.fileSizeBytes > MAX_ARTWORK_SIZE_BYTES
  ) {
    throw new ArtworkUploadValidationError(
      "Uploaded artwork has an invalid file size",
    );
  }

  if (metadata.fileSizeBytes !== upload.expectedSize) {
    throw new ArtworkUploadValidationError(
      "Uploaded artwork file size does not match the authorized upload",
    );
  }

  const artwork = await completeArtworkDeliveryRepository({
    letterId,
    storageKey: upload.storageKey,
    contentType: upload.contentType,
    fileSizeBytes: metadata.fileSizeBytes,
    isAnonymous: input.isAnonymous,
    deliveredAt: new Date(),
  });

  if (!artwork) {
    throw new LetterNotClaimedByArtistError();
  }

  findLetterById(letterId).then((letter) => {
    if (letter) {
      createAndDispatchNotification({
        userId: Number(letter.senderId),
        letterId,
        type: "ARTWORK_DELIVERED",
        title: "🎨 Artwork Delivered!",
        message: `An artist has illustrated your letter "${letter.title}"!`,
      }).catch(console.error);
    }
  }).catch(console.error);

  return artwork;
};