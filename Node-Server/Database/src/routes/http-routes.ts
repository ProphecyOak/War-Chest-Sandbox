import express from "express";
import { Request, Response } from "express";
import { DataSource } from "typeorm";
import { Player } from "../entity/Player";
import { Room } from "../entity/Room";
import * as WCPP from "wcpp-utils";

export async function setup_HTTP_routes(app: express.Express, db: DataSource) {
  await databaseTest(db);
  app.use(express.json());
  app.get("/test", (req: Request, res: Response) => {
    res.send("Test route to wcpp database works.");
  });

  app.post("/new-player", async (req: Request, res: Response) => {
    const new_player = new Player();
    await db.getRepository(Player).insert(new_player);
    res.status(201).json({ uuid: new_player.id });
  });

  app.get("/player", async (req: Request, res: Response) => {
    try {
      const player = await db.manager
        .createQueryBuilder(Player, "player")
        .where("player.id = :id", { id: req.query.id })
        .getOne();
      if (!player) throw new Error("Invalid id.");
      res.json({ player });
    } catch (err) {
      res.status(400).json({ error: (err as Error).message });
    }
  });
}

async function databaseTest(db: DataSource) {
  console.log("Beginning database test...");
  const room = new Room();
  console.log((await db.manager.save(room)).id);
}
