import { UUID } from "crypto";

export { ObligationStack, ObligationType };

enum ObligationType {
  PLAY_COIN = "PLAY_COIN",
}

interface Obligation {
  player: UUID;
  obligation_type: ObligationType;
  context?: unknown;
}

class ObligationStack {
  private stack: Array<Obligation> = [];

  get empty() {
    return this.stack.length == 0;
  }

  push(new_obligation: Obligation) {
    this.stack.push(new_obligation);
  }
  peek(): Obligation | undefined {
    if (this.empty) return undefined;
    return this.stack[this.stack.length - 1];
  }
  pop(): Obligation | undefined {
    if (this.empty) return undefined;
    const top = this.stack[this.stack.length - 1];
    return this.stack.pop();
  }
}
