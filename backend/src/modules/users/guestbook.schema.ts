import { z } from "zod";

export const createGuestbookEntrySchema = z.object({
  message: z
    .string()
    .trim()
    .min(1, "Message is required")
    .max(300, "Message must be at most 300 characters"),
});

export type CreateGuestbookEntryInput = z.infer<
  typeof createGuestbookEntrySchema
>;