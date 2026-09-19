import { Router } from "express";
import { requireAuthentication } from "../../middleware/auth.middleware.js";
import { findLetterById } from "../letters/letter.repository.js";
import { inspireArtistWithMuse } from "./muse.agent.js";
import { polishLetterWithScribe } from "./scribe.agent.js";
import { sanitizeLetterWithGuardian } from "./guardian.agent.js";

const router = Router();

router.post("/muse/inspire/:letterId", requireAuthentication, async (req, res) => {
  const letterId = parseInt(req.params["letterId"] as string, 10);

  if (isNaN(letterId)) {
    res.status(400).json({ error: "Invalid letter ID" });
    return;
  }

  const letter = await findLetterById(letterId);
  if (!letter) {
    res.status(404).json({ error: "Letter not found" });
    return;
  }

  try {
    const inspiration = await inspireArtistWithMuse(letter.title, letter.message);
    res.json({
      success: true,
      letterId,
      inspiration,
    });
  } catch (error) {
    console.error("Muse Agent Error:", error);
    res.status(500).json({ error: "Failed to generate inspiration" });
  }
});

router.post("/scribe/polish", requireAuthentication, async (req, res) => {
  const { draft } = req.body;
  if (!draft || typeof draft !== "string" || draft.trim().length === 0) {
    res.status(400).json({ error: "Draft text is required" });
    return;
  }

  try {
    const styles = await polishLetterWithScribe(draft);
    res.json({
      success: true,
      draft,
      styles,
    });
  } catch (error) {
    console.error("Scribe Agent Error:", error);
    res.status(500).json({ error: "Failed to polish draft" });
  }
});

router.post("/guardian/check", (req, res) => {
  const { text } = req.body;
  if (!text || typeof text !== "string") {
    res.status(400).json({ error: "Text is required" });
    return;
  }

  const result = sanitizeLetterWithGuardian(text);
  res.json({
    success: true,
    result,
  });
});

router.get("/spotify/embed", (_req, res) => {
  const trackId = _req.query["trackId"] as string | undefined;
  if (!trackId) {
    res.json({
      embedUrl:
        "https://open.spotify.com/embed/playlist/37i9dQZF1DX3rxVfibe1L0?utm_source=generator&theme=0",
    });
    return;
  }

  res.json({
    embedUrl: `https://open.spotify.com/embed/track/${trackId}?utm_source=generator&theme=0`,
  });
});

export default router;
