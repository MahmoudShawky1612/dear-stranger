import { prisma } from "../../lib/prisma.js";

/**
 * Automatically releases any letters that were claimed more than `hours` ago
 * but have not had their artwork delivered yet.
 */
export const releaseExpiredClaimedLetters = async (hours: number = 72): Promise<number> => {
  const thresholdDate = new Date(Date.now() - hours * 60 * 60 * 1000);

  const result = await prisma.letter.updateMany({
    where: {
      status: "CLAIMED",
      claimedAt: {
        lt: thresholdDate,
      },
      artwork: null,
    },
    data: {
      status: "AVAILABLE",
      artistId: null,
      claimedAt: null,
    },
  });

  if (result.count > 0) {
    console.log(`[ClaimTimeout] Automatically released ${result.count} expired claimed letter(s) back to the mail board.`);
  }

  return result.count;
};

/**
 * Initializes a background worker that checks for expired claims every intervalMinutes.
 */
export const startClaimTimeoutScheduler = (intervalMinutes: number = 30) => {
  releaseExpiredClaimedLetters().catch(console.error);

  setInterval(() => {
    releaseExpiredClaimedLetters().catch(console.error);
  }, intervalMinutes * 60 * 1000);
};
