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
    res.status(201).json({ status: "created", uuid: new_player.id });
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
  const room = new Room();
  console.log((await db.manager.save(room)).id);
}
