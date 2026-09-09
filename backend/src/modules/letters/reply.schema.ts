import { z } from "zod";

export const createReplySchema = z.object({
  message: z
    .string()
    .trim()
    .min(1, "Message is required")
    .max(500, "Reply must be at most 500 characters long"),
});

export type CreateReplyInput = z.infer<typeof createReplySchema>;