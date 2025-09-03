import {
  Entity,
  PrimaryGeneratedColumn,
  OneToOne,
  OneToMany,
  Column,
} from "typeorm";
import { Room } from "./Room";
import { Coin } from "./Coin";

export enum DECISION_TYPE {
  MOVE,
}

export type IGameDecision = {
  actor: string; // Player ID
  decision_type: DECISION_TYPE;
  decision_details: Object;
};

@Entity()
export class Game {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @OneToOne(() => Room, (room) => room.game, { eager: true })
  room: Room;

  @OneToMany(() => Coin, (coin) => coin.game)
  coins: Coin[];

  @Column({ type: "jsonb" })
  history: IGameDecision[];
}
