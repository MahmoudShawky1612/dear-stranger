import { createHash, randomBytes } from "node:crypto";

const SESSION_TTL_MS = 7 * 24 * 60 * 60 * 1000;

export const generateSessionToken = (): string => {
  return randomBytes(32).toString("base64url");
};

export const hashSessionToken = (token: string): string => {
  return createHash("sha256").update(token).digest("hex");
};

export const getSessionExpiration = (): Date => {
  return new Date(Date.now() + SESSION_TTL_MS);
};