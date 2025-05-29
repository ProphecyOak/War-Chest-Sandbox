import { randomUUID, UUID } from "crypto";
import { WebSocket } from "ws";
import { send_to_peer } from "./server_tools";
import { Game } from "./components/game";
import { Player } from "./components/player";

export { Room };

class Room {
  static rooms = new Map<UUID, Room>();

  players = new Map<UUID, Player>();
  sockets = new Map<UUID, WebSocket>();
  _host: UUID;
  id: UUID;
  game: Game;

  set host(new_host: UUID) {
    this._host = new_host;
  }
  get host() {
    return this._host;
  }

  constructor(creator: UUID, ws: WebSocket) {
    this._host = creator;
    this.id = randomUUID();
    this.add_peer(creator, ws);
    this.game = new Game(this.sockets);
    Room.rooms.set(this.id, this);
    console.log(`Room: ${this.id} created.`);
  }

  add_peer(peer_id: UUID, ws: WebSocket) {
    this.players.set(peer_id, new Player(peer_id));
    this.sockets.set(peer_id, ws);
    this.broadcast("player_joined", { name: peer_id }, peer_id);
  }

  remove_peer(peer_id: UUID) {
    this.players.delete(peer_id);
    this.sockets.delete(peer_id);
    switch (this.players.size) {
      case 1:
        if (this.players.has(this.host)) break;
        this.host = Array.from(this.players.entries())[0][0];
        send_to_peer(this.sockets.get(this.host)!, "make_host");
        break;
      case 0:
        console.log(`Removing room: ${this.id}`);
        Room.rooms.delete(this.id);
        break;
    }
  }

  broadcast(op_code: string, extras?: {}, origin_id?: UUID) {
    const origin_ws = origin_id ? this.sockets.get(origin_id) : undefined;
    this.sockets.forEach((ws: WebSocket) => {
      if (ws == origin_ws) return;
      send_to_peer(ws, op_code, extras);
    });
  }
}
