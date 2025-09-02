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

  app.post("/player", async (req: Request, res: Response) => {
    const new_player = new Player();
    await db.getRepository(Player).insert(new_player);
    res.status(201).json({ uuid: new_player.id });
  });

  app.get("/player", async (req: Request, res: Response) => {
    const player = await db
      .getRepository(Player)
      .findOneBy({ id: req.query.id as string });
    if (!player) throw new Error("Invalid id.");
    res.json({ player });
  });

  app.post("/room", async (req: Request, res: Response) => {
    const current_player = await db
      .getRepository(Player)
      .findOneBy({ id: req.query.id as string });
    if (current_player.room != null) {
      res.status(409).json({ error: "Already in room." });
      return;
    }
    const new_room = new Room();
    await db.getRepository(Room).insert(new_room);
    res.status(201).json({ uuid: new_room.id });
  });
}

async function databaseTest(db: DataSource) {
  console.log("Beginning database test...");
  const room = new Room();
  console.log((await db.manager.save(room)).id);
}
