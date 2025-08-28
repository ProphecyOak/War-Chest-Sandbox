import {
  Entity,
  PrimaryGeneratedColumn,
  OneToMany,
  ManyToOne,
  Column,
} from "typeorm";
import { Coin } from "./Coin";
import { Room } from "./Room";

export enum PLAYER_ROLE {
  PLAYER,
  SPECTATOR,
}

@Entity()
export class Player {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @OneToMany(() => Coin, (coin) => coin.player_id)
  coins: Coin[];

  @ManyToOne(() => Room, (room) => room.players, { nullable: true })
  room_id: string;

  @Column({ type: "enum", enum: PLAYER_ROLE, default: PLAYER_ROLE.SPECTATOR })
  role: PLAYER_ROLE;

  @Column({ default: false })
  host: boolean;
}
