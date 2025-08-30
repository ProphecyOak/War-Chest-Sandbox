import express from "express";
import { Request, Response } from "express";

export async function setup_HTTP_routes(
  app: express.Express,
  lookupService: (name: string) => Promise<string | null>
) {
  app.use(express.json());
  const get_db_url = get_url_factory("wcpp-db", lookupService);

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

function get_url_factory(
  name: string,
  lookupService: (name: string) => Promise<string | null>
) {
  let url: string | null = null;
  return async () => {
    if (url == null) url = (await lookupService(name)) as string;
    return url;
  };
}
