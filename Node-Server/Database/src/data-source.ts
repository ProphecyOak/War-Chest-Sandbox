import "reflect-metadata";
import { DataSource } from "typeorm";
import { Player } from "./entity/Player";
import { Unit } from "./entity/Unit";
import { Coin } from "./entity/Coin";
import { Room } from "./entity/Room";

export const AppDataSource = new DataSource({
  type: "postgres",
  host: "postgres",
  port: 5432,
  username: "test",
  password: "test",
  database: "test",
  synchronize: true,
  logging: false,
  entities: [Room, Player, Unit, Coin],
  migrations: [],
  subscribers: [],
});
