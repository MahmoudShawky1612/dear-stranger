import { z } from "zod";

export const updateProfileSchema = z.object({
  displayName: z
    .string()
    .trim()
    .min(1)
    .max(50)
    .nullable()
    .optional(),

  bio: z
    .string()
    .trim()
    .max(300)
    .nullable()
    .optional(),

  location: z
    .string()
    .trim()
    .max(100)
    .nullable()
    .optional(),

  favoriteMedium: z
    .string()
    .trim()
    .max(50)
    .nullable()
    .optional(),

  currentlyDrawing: z
    .string()
    .trim()
    .max(120)
    .nullable()
    .optional(),
});

export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;