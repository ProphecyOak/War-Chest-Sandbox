export { Unit };

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
