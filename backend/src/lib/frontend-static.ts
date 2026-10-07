import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import type { Express, Request, Response, NextFunction } from "express";
import express from "express";

const dirOfThisFile = path.dirname(fileURLToPath(import.meta.url));

const candidateDirs = (): string[] => {
  const fromEnv = process.env["PUBLIC_DIR"];
  return [
    ...(fromEnv ? [fromEnv] : []),
    path.join(process.cwd(), "public"),
    path.join(dirOfThisFile, "../public"),
    path.join(dirOfThisFile, "../../public"),
  ];
};

export const attachFrontend = (app: Express): void => {
  const publicDir = candidateDirs().find((dir) =>
    fs.existsSync(path.join(dir, "index.html")),
  );

  if (!publicDir) {
    console.warn("No Flutter web build in public/; API-only mode");
    return;
  }

  console.log(`Serving Flutter web from ${publicDir}`);
  app.use(express.static(publicDir, { index: false }));

  app.use((request: Request, response: Response, next: NextFunction) => {
    if (request.method !== "GET" && request.method !== "HEAD") {
      next();
      return;
    }
    if (request.path.startsWith("/api")) {
      next();
      return;
    }
    response.sendFile(path.join(publicDir, "index.html"));
  });
};
