import { z } from "zod";

export const createAvatarUploadSchema = z.object({
  contentType: z.enum(["image/jpeg", "image/png", "image/webp"]),
  fileSizeBytes: z.number().int().positive().max(2 * 1024 * 1024),
});

export type CreateAvatarUploadInput = z.infer<typeof createAvatarUploadSchema>;

export const completeAvatarSchema = z.object({
  storageKey: z.string().min(1),
});

export type CompleteAvatarInput = z.infer<typeof completeAvatarSchema>;