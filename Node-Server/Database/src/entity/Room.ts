import { Entity, PrimaryGeneratedColumn, OneToMany, OneToOne } from "typeorm";
import { Player } from "./Player";
import { Game } from "./Game";

@Entity()
export class Room {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @OneToMany(() => Player, (player) => player.room)
  players: Player[];

  @OneToOne(() => Game, (game) => game.room)
  game: Game;
}
