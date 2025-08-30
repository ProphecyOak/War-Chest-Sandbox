import express from "express";
import { Request, Response } from "express";
import { DataSource } from "typeorm";
import { Player, PLAYER_ROLE } from "../entity/Player";
import { Room } from "../entity/Room";

export async function setup_HTTP_routes(app: express.Express, db: DataSource) {
  console.log("Beginning database test...");
  const room = new Room();
  await db.manager.save(room);
  const player1 = new Player();
  player1.host = true;
  player1.role = PLAYER_ROLE.PLAYER;
  const player2 = new Player();
  player2.host = false;
  player2.role = PLAYER_ROLE.PLAYER;
  const player3 = new Player();
  player3.host = false;
  player3.role = PLAYER_ROLE.SPECTATOR;
  await db.manager.save(player1);
  await db.manager.save(player2);
  await db.manager.save(player3);
  room.players = [player1, player2, player3];
  await db.manager.save(room);
  const rooms = await db.manager
    .createQueryBuilder(Room, "room")
    .leftJoinAndSelect("room.players", "player")
    .getMany();

  console.log(
    rooms
      .map(
        (room: Room) =>
          `Room: ${room.id}\n\t${room.players
            .map(
              (player: Player) =>
                `Player: ${player.id}${player.host ? ", host" : ""}.`
            )
            .join("\n\t")}`
      )
      .join("\n")
  );

  console.log("Database tests completed.");
  app.get("/test", (req: Request, res: Response) => {
    res.send("Test route to wcpp database works.");
  });
}
