import { z } from "zod";

export const createArtworkUploadSchema = z.object({
  contentType: z.enum(
    ["image/jpeg", "image/png", "image/webp"],
    {
      message: "Only JPEG, PNG, and WebP images are supported",
    },
  ),

  fileSizeBytes: z
    .number()
    .int()
    .positive()
    .max(10 * 1024 * 1024, "Artwork must be 10 MB or smaller"),
});

export const completeArtworkSchema = z.object({
  storageKey: z.string().min(1, "Storage key is required"),
  isAnonymous: z.boolean(),
});

export type CompleteArtworkInput = z.infer<
  typeof completeArtworkSchema
>;

export type CreateArtworkUploadInput = z.infer<
  typeof createArtworkUploadSchema
>;