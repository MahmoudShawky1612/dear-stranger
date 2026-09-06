import type { Request, Response } from "express";

export const getHello = (_request: Request, response: Response): void => {
  response.json({
    message: "Hello from Dear Stranger's API!",
  });
};
