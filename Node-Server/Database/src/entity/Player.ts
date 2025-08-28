import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from "typeorm";
import { Coin } from "./Coin";

@Entity()
export class Player {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @OneToMany(() => Coin, (coin) => coin.player_id)
  coins: Coin[];
}
