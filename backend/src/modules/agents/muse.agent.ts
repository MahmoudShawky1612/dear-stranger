import { GoogleGenAI } from "@google/genai";

export interface MuseInspiration {
  mood: string;
  palette: {
    name: string;
    hex: string;
  }[];
  visualMetaphors: string[];
  compositionTip: string;
  musicVibe: string;
}

const generateSmartFallback = (title: string, message: string): MuseInspiration => {
  const lowerMsg = (title + " " + message).toLowerCase();
  const isMelancholy =
    lowerMsg.includes("sad") ||
    lowerMsg.includes("miss") ||
    lowerMsg.includes("alone") ||
    lowerMsg.includes("dark") ||
    lowerMsg.includes("rain");

  if (isMelancholy) {
    return {
      mood: "Melancholic Nostalgia & Longing",
      palette: [
        { name: "Vintage Parchment", hex: "#E8D8C8" },
        { name: "Faded Indigo", hex: "#2C3E50" },
        { name: "Dusty Rose", hex: "#C08081" },
        { name: "Sepia Mist", hex: "#705848" },
      ],
      visualMetaphors: [
        "A lone open window overlooking a rainy, dimly lit street.",
        "An unread envelope casting a long shadow on an old wooden desk.",
        "A silhouette standing under a solitary street lamp.",
      ],
      compositionTip:
        "Use soft watercolor textures with heavy contrasting shadows to emphasize distance and quiet contemplation.",
      musicVibe: "Slow acoustic piano, quiet lo-fi beats, or ambient rain sounds.",
    };
  }

  return {
    mood: "Warm Serendipity & Hope",
    palette: [
      { name: "Warm Amber", hex: "#F39C12" },
      { name: "Morning Sky", hex: "#3498DB" },
      { name: "Linen White", hex: "#FDFEFE" },
      { name: "Terracotta", hex: "#D35400" },
    ],
    visualMetaphors: [
      "Sunlight filtering through morning blinds onto an open sketchbook.",
      "A golden paper airplane soaring between city rooftops.",
      "Two distant silhouettes crossing paths on an autumn bridge.",
    ],
    compositionTip:
      "Focus on warm golden-hour lighting and flowing linework to create a gentle, inviting atmosphere.",
    musicVibe: "Warm acoustic guitar, indie folk, or nostalgic dream pop.",
  };
};

export const inspireArtistWithMuse = async (
  letterTitle: string,
  letterMessage: string,
): Promise<MuseInspiration> => {
  const apiKey = process.env["GEMINI_API_KEY"];

  if (!apiKey) {
    return generateSmartFallback(letterTitle, letterMessage);
  }

  try {
    const ai = new GoogleGenAI({ apiKey });
    const prompt = `
You are "The Muse" in a nostalgic creative platform called "Dear Stranger".
Your purpose is to provide creative inspiration to an artist who is about to illustrate a personal letter from a stranger.

Letter Title: "${letterTitle}"
Letter Content: "${letterMessage}"

Analyze the emotional depth and imagery of this letter.
Return strictly a JSON object with this exact structure:
{
  "mood": "Short emotional mood summary",
  "palette": [
    {"name": "Color 1 Name", "hex": "#HEX1"},
    {"name": "Color 2 Name", "hex": "#HEX2"},
    {"name": "Color 3 Name", "hex": "#HEX3"},
    {"name": "Color 4 Name", "hex": "#HEX4"}
  ],
  "visualMetaphors": [
    "Visual idea 1",
    "Visual idea 2",
    "Visual idea 3"
  ],
  "compositionTip": "Advice on art style, lighting, or texture",
  "musicVibe": "Suggested ambient or musical tone for painting"
}
`;

    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: prompt,
      config: {
        responseMimeType: "application/json",
      },
    });

    const resultText = response.text;
    if (!resultText) {
      return generateSmartFallback(letterTitle, letterMessage);
    }

    return JSON.parse(resultText) as MuseInspiration;
  } catch (error) {
    console.error("Muse Agent failed, falling back:", error);
    return generateSmartFallback(letterTitle, letterMessage);
  }
};
