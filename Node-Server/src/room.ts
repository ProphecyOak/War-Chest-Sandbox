import { randomUUID, UUID } from "crypto";

export { Room };

class Room {
  static rooms: Map<UUID, Room> = new Map<UUID, Room>();
  peers: String[] = [];
  host: UUID;
  id: UUID;

  constructor(creator: UUID) {
    this.host = creator;
    this.id = randomUUID();
    Room.rooms.set(this.id, this);
  }

  add_peer(peer_id: UUID) {
    this.peers.push(peer_id);
  }
  broadcast(message: {}) {}
}
