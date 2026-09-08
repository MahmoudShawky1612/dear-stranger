export const SESSION_COOKIE_NAME = "dear-stranger-session";

export const sessionCookieOptions = {
  httpOnly: true,
  secure: process.env["NODE_ENV"] === "production",
  sameSite: "strict" as const,
  path: "/",
};