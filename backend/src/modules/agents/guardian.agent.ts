export interface GuardianSanitizationResult {
  isSafe: boolean;
  sanitizedMessage: string;
  piiDetected: boolean;
  notes?: string;
}

export const sanitizeLetterWithGuardian = (
  text: string,
): GuardianSanitizationResult => {
  let sanitized = text;
  let piiDetected = false;

  const phonePattern = /(\+?\d{1,3}[-.\s]?)?(\(?\d{2,4}\)?[-.\s]?)?\d{3,4}[-.\s]?\d{3,4}/g;
  if (phonePattern.test(sanitized)) {
    sanitized = sanitized.replace(phonePattern, "[phone number redacted]");
    piiDetected = true;
  }

  const emailPattern = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g;
  if (emailPattern.test(sanitized)) {
    sanitized = sanitized.replace(emailPattern, "[email redacted]");
    piiDetected = true;
  }

  const socialPattern = /(@[a-zA-Z0-9_]{3,25}|(instagram|twitter|tiktok|snapchat|telegram)\.com\/[a-zA-Z0-9_.]+)/gi;
  if (socialPattern.test(sanitized)) {
    sanitized = sanitized.replace(socialPattern, "[social handle redacted]");
    piiDetected = true;
  }

  return {
    isSafe: true,
    sanitizedMessage: sanitized,
    piiDetected,
    notes: piiDetected ? "Personal contact information was masked for stranger privacy." : undefined,
  };
};
