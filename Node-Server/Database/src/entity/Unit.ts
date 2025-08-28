import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from "typeorm";

@Entity()
export class Unit {
  @PrimaryGeneratedColumn()
  id: number;
}
