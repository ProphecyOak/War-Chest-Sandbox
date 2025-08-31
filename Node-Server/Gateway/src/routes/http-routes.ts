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
    const db_url = await get_db_url();
    const result = await fetch(`${db_url}${req.originalUrl.substring(3)}`);
    res.status(result.status).json(await result.json());
  });

  app.get("/connect", async (req: Request, res: Response) => {
    const db_url = await get_db_url();
    const result = await fetch(`${db_url}/new-player`, { method: "POST" });
    res.status(result.status).json(await result.json());
  });
}
