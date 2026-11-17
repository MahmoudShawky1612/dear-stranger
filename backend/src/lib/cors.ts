const localhostOrigins = [
  /^http:\/\/localhost(:\d+)?$/,
  /^http:\/\/127\.0\.0\.1(:\d+)?$/,
];

const extraOrigins = () =>
  [process.env["FRONTEND_ORIGIN"], process.env["RENDER_EXTERNAL_URL"]]
    .filter((value): value is string => Boolean(value))
    .map((value) => value.replace(/\/$/, ""));

export const isAllowedOrigin = (origin: string | undefined): boolean => {
  if (!origin) return true;
  if (localhostOrigins.some((re) => re.test(origin))) return true;
  return extraOrigins().includes(origin);
};
