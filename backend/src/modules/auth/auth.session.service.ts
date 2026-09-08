import {
  createSession,
  findSessionByTokenHash,
  updateSessionLastUsedAt,
  deleteSessionById,
} from "./auth.repository.js";
import {
  generateSessionToken,
  getSessionExpiration,
  hashSessionToken,
} from "./auth.session.js";

export const createUserSession = async (userId: number) => {
  const token = generateSessionToken();
  const tokenHash = hashSessionToken(token);
  const expiresAt = getSessionExpiration();

  await createSession({
    userId,
    tokenHash,
    expiresAt,
  });

  return {
    token,
    expiresAt,
  };
};

export const getSession = async (token: string) => {
  const tokenHash = hashSessionToken(token);

  const session = await findSessionByTokenHash(tokenHash);

  if (!session) {
    return null;
  }

  if (session.expiresAt <= new Date()) {
    await deleteSessionById(session.id);
    return null;
  }

  await updateSessionLastUsedAt(session.id);

  return session;
};

export const deleteUserSession = async (token: string) => {
  const tokenHash = hashSessionToken(token);

  const session = await findSessionByTokenHash(tokenHash);

  if (!session) {
    return;
  }

  await deleteSessionById(session.id);
};