import { randomUUID, UUID } from "crypto";
import { WebSocket } from "ws";
import { send_to_peer } from "./server_tools";

export { Room };

class Room {
  static rooms = new Map<UUID, Room>();

  players = new Map<UUID, Player>();
  sockets = new Map<UUID, WebSocket>();
  host: UUID;
  id: UUID;
  game?: Game;

  constructor(creator: UUID, ws: WebSocket) {
    this.host = creator;
    this.id = randomUUID();
    this.add_peer(creator, ws);
    Room.rooms.set(this.id, this);
    console.log(`Room: ${this.id} created.`);
  }

  add_peer(peer_id: UUID, ws: WebSocket) {
    this.players.set(peer_id, new Player(peer_id));
    this.sockets.set(peer_id, ws);
    this.broadcast("player_joined", { name: peer_id }, ws);
  }

  remove_peer(peer_id: UUID) {
    this.players.delete(peer_id);
    this.sockets.delete(peer_id);
    if (this.players.size == 0) {
      console.log(`Removing room: ${this.id}`);
      Room.rooms.delete(this.id);
    }
  }

  broadcast(op_code: string, extras?: {}, origin_ws?: WebSocket) {
    this.sockets.forEach((ws: WebSocket) => {
      if (ws == origin_ws) return;
      send_to_peer(ws, op_code, extras);
    });
  }
}

type hex_coord = [number, number];

class Game {
  round: number = 0;
  initiative_taken: number = -1;
  active_player: UUID;
  turn_order: UUID[];
  board: Board;
  players: Player[];
  teams: { id: number; controlled: hex_coord[]; color: string }[] = [];
  decrees: string[] = [];

  constructor(players: Player[], board: Board) {
    this.players = players;
    this.board = board;
    this.turn_order = players.map((player: Player) => player.id);
    this.active_player = this.turn_order[0];
  }
}

class Player {
  id: UUID;
  team: number = -1;
  has_initiative: boolean = false;
  units: Unit[] = [];

  constructor(id: UUID) {
    this.id = id;
  }
}

interface Board {
  player_count: number;
  winning_score: number;
  traversable_hexes: hex_coord[];
  control_spots: { [key: number]: hex_coord[] };
  forts: hex_coord[];
  poison: { [unit_id: string]: hex_coord }[];
}

enum UnitState {
  In_Supply = "In_Supply",
  In_Bag = "In_Bag",
  In_Hand = "In_Hand",
  Deployed = "Deployed",
  Discarded = "Discarded",
  Discarded_Face_Down = "Discarded_Face_Down",
}

interface Unit {
  id: number;
  unit_type_id: number;
  player_id: UUID;
  parent_unit_id: number;
  state: UnitState;
  position: hex_coord;
  quantity: number;
  image_name: string;
  bolster_units: Unit[];
}
