import { randomUUID, UUID } from "crypto";

export { Room };

class Room {
  static Rooms: Map<UUID, Room> = new Map<UUID, Room>();
  peers: String[] = [];
  host: UUID;
  id: UUID;

  constructor(creator: UUID) {
    this.host = creator;
    this.id = randomUUID();
  }

  broadcast(message: {}) {}
}
