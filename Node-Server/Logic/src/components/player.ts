import { UUID } from "crypto";
import { Unit } from "./unit";

export { Player };
class Player {
  id: UUID;
  team: number = -1;
  has_initiative: boolean = false;
  units: Unit[] = [];

  constructor(id: UUID) {
    this.id = id;
  }
}
