import express from "express";
import { Request, Response } from "express";
import { DataSource } from "typeorm";
import { Player, PLAYER_ROLE } from "../entity/Player";
import { Room } from "../entity/Room";

export async function setup_HTTP_routes(
  app: express.Express,
  lookupService: (name: string) => Promise<string | null>,
  db: DataSource
) {
  await databaseTest(db);
  app.use(express.json());
  app.get("/test", (req: Request, res: Response) => {
    res.send("Test route to wcpp database works.");
  });

  app.put("/player", (req: Request, res: Response) => {
    res.status(501).json({ error: "Route not implemented." });
  });

  app.get("/player", async (req: Request, res: Response) => {
    const player = await db.manager
      .createQueryBuilder(Player, "player")
      .where("player.id = :id", { id: req.query.id })
      .getOne();
    res.json({ status: "ok", player });
  });
}

async function databaseTest(db: DataSource) {
  console.log("Beginning database test...");
  const player1 = new Player();
  player1.host = true;
  player1.role = PLAYER_ROLE.PLAYER;
  console.log((await db.manager.save(player1)).id);
}
