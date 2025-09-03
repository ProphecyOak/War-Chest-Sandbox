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

  // TODO: Make a last_interaction column to
  // track last time user interacted with system.

  @OneToMany(() => Coin, (coin) => coin.player_id)
  coins: Coin[];

  @ManyToOne(() => Room, (room) => room.players, {
    nullable: true,
    eager: true,
  })
  room: Room;

  @Column({ type: "enum", enum: PLAYER_ROLE, default: PLAYER_ROLE.SPECTATOR })
  role: PLAYER_ROLE;

  @Column({ default: false })
  host: boolean;

  toString(): string {
    return `Player: ${this.id} ${this.host ? ", host" : ""}. Has the ${
      this.role
    } role.`;
  }
}
