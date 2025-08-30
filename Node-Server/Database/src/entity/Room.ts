import { Entity, PrimaryGeneratedColumn, OneToMany } from "typeorm";
import { Player } from "./Player";

@Entity()
export class Room {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @OneToMany(() => Player, (player) => player.room)
  players: Player[];
}
