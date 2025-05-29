export { Unit };

// enum UnitState {
//   In_Supply = "In_Supply",
//   In_Bag = "In_Bag",
//   In_Hand = "In_Hand",
//   Deployed = "Deployed",
//   Discarded = "Discarded",
//   Discarded_Face_Down = "Discarded_Face_Down",
// }

// interface Unit {
//   id: number;
//   unit_type_id: number;
//   player_id: UUID;
//   parent_unit_id: number;
//   state: UnitState;
//   position: hex_coord;
//   quantity: number;
//   image_name: string;
//   bolster_units: Unit[];
// }

type Maneuver = "attack" | "control" | "tactic" | "move";

type Trigger = "attacked" | "moved";

class Unit {
  coin_count: number;
  behaviors: Map<Trigger, Function> = new Map<Trigger, Function>();
  maneuvers: Map<Maneuver, Function> = new Map<Maneuver, Function>();

  constructor(coin_count: number) {
    this.coin_count = coin_count;
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
}
