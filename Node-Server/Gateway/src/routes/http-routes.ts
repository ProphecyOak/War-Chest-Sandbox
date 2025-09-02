import express from "express";
import { Request, Response } from "express";
import * as WCPP from "wcpp-utils";

export async function setup_HTTP_routes(app: express.Express) {
  app.use(express.json());
  const get_db_url = WCPP.get_url_factory("wcpp-db");

  app.get("/test", (req: Request, res: Response) => {
    res.send("Test route to wcpp gateway works.");
  });

  app.all(/\/db\/.*/, async (req: Request, res: Response) => {
    if (Object.entries(req.query).length == 0) {
      res.status(400).json({ error: "No query" });
      return;
    }
    const db_url = await get_db_url();
    const result = await fetch(
      `${db_url}${req.originalUrl.substring(3)}&external=true`
    );
    res.status(result.status).json(await result.json());
  });

  app.get("/connect", async (req: Request, res: Response) => {
    const db_url = await get_db_url();
    const result = await fetch(`${db_url}/player`, { method: "POST" });
    res.status(result.status).json(await result.json());
  });

  app.post("/room", async (req: Request, res: Response) => {
    const db_url = await get_db_url();
    const room_result = await fetch(`${db_url}/room`, { method: "POST" });
  });
}
