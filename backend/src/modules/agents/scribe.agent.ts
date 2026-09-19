import { GoogleGenAI } from "@google/genai";

export interface ScribePolishResult {
  vintage: string;
  poetic: string;
  midnightDiary: string;
  minimalist: string;
}

const generateSmartFallback = (draft: string): ScribePolishResult => {
  return {
    vintage: `Dearest stranger, across the quiet expanse of time, I write to you: ${draft}`,
    poetic: `Words suspended like dust in the amber light—${draft}`,
    midnightDiary: `It is past 2 AM, and the city is asleep, but this thought lingers: ${draft}`,
    minimalist: draft.trim(),
  };
};

export const polishLetterWithScribe = async (
  draftText: string,
): Promise<ScribePolishResult> => {
  const apiKey = process.env["GEMINI_API_KEY"];

  if (!apiKey || !draftText.trim()) {
    return generateSmartFallback(draftText);
  }

  try {
    const ai = new GoogleGenAI({ apiKey });
    const prompt = `
You are "The Scribe", a nostalgic typewriter assistant in "Dear Stranger".
Your goal is to help a user polish their rough message/thought into 4 authentic, human, emotional styles without altering the original core meaning:
1. vintage: Early 1900s handwritten letter tone.
2. poetic: Lyrical, atmospheric, evocative.
3. midnightDiary: Intimate, raw 2 AM journal entry.
4. minimalist: Concise, poignant, stripped to its essence.

Original Draft: "${draftText}"

Respond ONLY with a valid JSON object strictly matching this schema:
{
  "vintage": "...",
  "poetic": "...",
  "midnightDiary": "...",
  "minimalist": "..."
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
      return generateSmartFallback(draftText);
    }

    return JSON.parse(resultText) as ScribePolishResult;
  } catch (error) {
    console.error("Scribe Agent Error, falling back:", error);
    return generateSmartFallback(draftText);
  }
};
