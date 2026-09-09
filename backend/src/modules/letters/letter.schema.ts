import { z } from "zod";

export const createLetterSchema = z.object({
  title: z
    .string()
    .trim()
    .min(1, "Title is required")
    .max(100, "Title must be at most 100 characters long"),

  message: z
    .string()
    .trim()
    .min(1, "Message is required")
    .max(2000, "Message must be at most 2000 characters long"),

  isAnonymous: z.boolean().default(false),
});

export const paginationSchema = z.object({
  limit: z.coerce.number().int().min(1).max(50).default(20),
  cursor: z.coerce.number().int().positive().optional(),
});

export type PaginationInput = z.infer<typeof paginationSchema>;
export type CreateLetterInput = z.infer<typeof createLetterSchema>;