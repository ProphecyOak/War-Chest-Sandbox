import {
  Entity,
  PrimaryGeneratedColumn,
  ManyToOne,
  OneToOne,
  Column,
} from "typeorm";
import { Unit } from "./Unit";
import { Player } from "./Player";
import { Game } from "./Game";

export enum COIN_STATE {
  IN_SUPPLY,
  IN_BAG,
  TOP_OF_BAG,
  IN_HAND,
  DEPLOYED,
  ELIMINATED,
  DISCARDED_FACEUP,
  DISCARDED_FACEDOWN,
}

@Entity()
export class Coin {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Unit)
  unit_type_id: number;

  @ManyToOne(() => Player, (player) => player.coins)
  player_id: string;

  @OneToOne(() => Coin, (coin) => coin.child_coin_id, { nullable: true })
  parent_coin_id: number;

  @OneToOne(() => Coin, (coin) => coin.parent_coin_id, { nullable: true })
  child_coin_id: number;

  @Column({ type: "enum", enum: COIN_STATE, default: COIN_STATE.IN_SUPPLY })
  state: COIN_STATE;

  @ManyToOne(() => Game, (game) => game.coins)
  game: Game;
}
