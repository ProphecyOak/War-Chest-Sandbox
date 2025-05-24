import { randomUUID, UUID } from "crypto";
import { WebSocket } from "ws";
import { send_to_peer } from "./server_tools";

export { Room };

class Room {
  static rooms = new Map<UUID, Room>();

  players = new Map<UUID, Player>();
  sockets = new Map<UUID, WebSocket>();
  _host: UUID;
  id: UUID;
  game: Game;
  action_stack = [];

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
    this.game = new Game();
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

type hex_coord = [number, number];

class Game {
  round: number = 0;
  initiative_taken: number = -1;
  active_player: UUID;
  turn_order: UUID[] = [];
  board?: Board;
  players: Player[] = [];
  teams: { id: number; controlled: hex_coord[]; color: string }[] = [];
  decrees: string[] = [];

  get has_board() {
    return this.board != undefined;
  }

  constructor() {
    this.active_player = this.turn_order[0];
  }

  set_players(players: Map<UUID, Player>) {
    this.players = [];
    this.turn_order = [];
    Array.from(players.entries()).forEach(([id, player]: [UUID, Player]) => {
      this.turn_order.push(id);
      this.players.push(player);
    });
  }

  set_board(board_data: BoardData) {
    try {
      this.board = new Board(board_data);
      return true;
    } catch {
      console.log(`Board initialization failed from BoardData:\n${board_data}`);
      return false;
    }
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

interface BoardData {
  player_count: number;
  winning_score: number;
  traversable_hexes: hex_coord[];
  control_spots: hex_coord[][];
}

class Board {
  player_count: number;
  winning_score: number;
  traversable_hexes: hex_coord[];
  control_spots: hex_coord[][]; // -1 for unclaimed
  forts: hex_coord[] = [];
  poison: { [unit_id: string]: hex_coord }[] = [];

  constructor(boardData: BoardData) {
    this.player_count = boardData.player_count;
    this.winning_score = boardData.winning_score;
    this.traversable_hexes = boardData.traversable_hexes;
    this.control_spots = boardData.control_spots;
  }
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
