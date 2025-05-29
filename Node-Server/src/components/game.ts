import { UUID } from "crypto";
import { WebSocket } from "ws";
import { Player } from "./player";
import { ObligationStack, ObligationType } from "./obligation_stack";
import { Board, BoardData, hex_coord } from "./board";
import { send_to_peer } from "../server_tools";
import { shuffle } from "../tools";
import { pikeman } from "../resources/unit_scripts/pikeman";

export { Game };

class Game {
  round: number = 0;
  initiative_taken: number = -1;
  private obligations = new ObligationStack();
  turn_order: UUID[] = [];
  board?: Board;
  players: Player[] = [];
  teams: { id: number; controlled: hex_coord[]; color: string }[] = [];
  decrees: string[] = [];
  game_over: boolean = false;
  private sockets: Map<UUID, WebSocket>;
  private broadcast: (op_code: string, extras?: {}, origin_id?: UUID) => void;

  get has_board() {
    return this.board != undefined;
  }

  constructor(
    sockets: Map<UUID, WebSocket>,
    broadcast_func: (op_code: string, extras?: {}, origin_id?: UUID) => void
  ) {
    this.sockets = sockets;
    this.broadcast = broadcast_func;
  }

  set_players(players: Map<UUID, Player>) {
    this.players = [];
    this.turn_order = [];
    Array.from(players.entries()).forEach(([id, player]: [UUID, Player]) => {
      this.turn_order.push(id);
      this.players.push(player);
    });
    this.turn_order = shuffle(this.turn_order);
    let current_team = 0;
    this.players.forEach((player: Player) => {
      player.team = current_team;
      current_team = (current_team + 1) % this.board!.player_count;
    });
    for (let i = 0; i < this.board!.player_count; i++) {
      // FIXME TEAM CREATION
      this.teams.push({
        id: i,
        controlled: [],
        color: "",
      });
    }
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

  start_draft() {
    this.players[0].units.push(pikeman.create_coin(this.players[0].id));
    this.broadcast("game_state", {
      game_state: this.get_sendable(),
    });
    this.start_round();
  }

  start_round() {
    for (let x = 3; x > 0; x--)
      this.turn_order.forEach((player: UUID) => {
        this.obligations.push({
          player,
          obligation_type: ObligationType.PLAY_COIN,
        });
      });
    this.process_obligations();
  }

  process_obligations() {
    while (!this.game_over && !this.obligations.empty) {
      const current_obligation = this.obligations.pop();
      send_to_peer(
        this.sockets.get(current_obligation!.player)!,
        "obligation",
        {
          obligation_type: current_obligation!.obligation_type,
          context: current_obligation!.context,
        }
      );
    }
    // if (!this.game_over) {
    //   this.start_round();
    //   return;
    // }
    console.log("Game Over");
  }

  get_sendable() {
    const { obligations, sockets, ...clone } = this;
    return clone;
  }
}
