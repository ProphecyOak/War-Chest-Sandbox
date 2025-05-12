import { randomUUID, UUID } from "crypto";
import { WebSocket } from "ws";
import { send_to_peer } from "./server_tools";

export { Room };

class Room {
  static rooms: Map<UUID, Room> = new Map<UUID, Room>();
  players: Player[] = [];
  sockets: WebSocket[] = [];
  host: UUID;
  id: UUID;
  game: Game;

  constructor(creator: UUID, ws: WebSocket) {
    this.host = creator;
    this.id = randomUUID();
    this.add_peer(creator, ws);
    Room.rooms.set(this.id, this);
    this.game = new Game(this.players, {} as Board);
    console.log(this.game);
  }

  add_peer(peer_id: UUID, ws: WebSocket) {
    this.players.push(new Player(peer_id));
    this.sockets.push(ws);
    this.broadcast("player_joined");
  }

  broadcast(op_code: string, extras?: {}) {
    this.sockets.forEach((ws: WebSocket) => {
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
