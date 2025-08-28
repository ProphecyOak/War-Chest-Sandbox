import express from "express";
import { Request, Response } from "express";

export function setup_HTTP_routes(app: express.Express) {
  app.get("/test", (req: Request, res: Response) => {
    res.send("Test route to wcpp gateway works.");
  });
}
