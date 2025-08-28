import { UUID } from "crypto";
import { hex_coord } from "./board";

export { Unit, UnitClass, UnitState };

enum UnitState {
  In_Supply = "In_Supply",
  In_Bag = "In_Bag",
  In_Hand = "In_Hand",
  Deployed = "Deployed",
  Discarded = "Discarded",
  Discarded_Face_Down = "Discarded_Face_Down",
}

interface Unit {
  class: UnitClass;
  id: number;
  unit_type_id: number;
  player_id: UUID;
  parent_unit_id: number | undefined;
  state: UnitState;
  position: hex_coord | undefined;
  image_id: string;
  bolster_units: Unit[];
}

type Maneuver = "attack" | "control" | "tactic" | "move";

type Trigger = "attacked" | "moved";

class UnitClass {
  static _next_id = 0;
  static get next_id(): number {
    UnitClass._next_id += 1;
    return UnitClass._next_id;
  }
  coin_count: number;
  behaviors: Map<Trigger, Function> = new Map<Trigger, Function>();
  maneuvers: Map<Maneuver, Function> = new Map<Maneuver, Function>();
  type_id: number;
  image_id: string;

  constructor(coin_count: number, type_id: number, image_id: string) {
    this.coin_count = coin_count;
    this.type_id = type_id;
    this.image_id = image_id;
  }

  can(action: Maneuver, behavior: () => {}) {
    this.maneuvers.set(action, behavior);
  }

  get_moves() {}

  on(action: Trigger, behavior: (trigger_info: {}) => {}) {
    this.behaviors.set(action, behavior);
  }

  react(action: Trigger, trigger_info: {}) {
    if (!this.behaviors.has(action)) return;
    this.behaviors.get(action)!(trigger_info);
  }

  create_coin(player_id: UUID, state: UnitState = UnitState.In_Supply): Unit {
    return {
      class: this,
      id: UnitClass.next_id,
      unit_type_id: this.type_id,
      player_id,
      parent_unit_id: undefined,
      state,
      position: undefined,
      image_id: this.image_id,
      bolster_units: [],
    };
  }
}
