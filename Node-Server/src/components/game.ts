import { randomUUID, UUID } from "crypto";
import { WebSocket } from "ws";
import { Player } from "./player";
import { ObligationStack, ObligationType } from "./obligation_stack";
import { Board, BoardData, hex_coord } from "./board";
import { send_to_peer } from "../server_tools";
import { shuffle } from "../tools";
import { pikeman } from "../resources/unit_scripts/pikeman";
import { Unit, UnitClass, UnitState } from "./unit";

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

  get has_board() {
    return this.board != undefined;
  }

  constructor(
    sockets: Map<UUID, WebSocket>,
    broadcast_func: (op_code: string, extras?: {}, origin_id?: UUID) => void
  ) {
    this.sockets = sockets;
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
    for (let p = 0; p < this.players.length; p++) {
      for (let c = 0; c < 3; c++) {
        this.players[p].units.push(
          pikeman.create_coin(this.players[p].id, UnitState.In_Hand)
        );
      }
    }
    this.broadcast();
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
    this.send_next_obligation();
  }

  send_next_obligation() {
    if (this.game_over) {
      console.log("Game Over!");
      return;
    }
    if (this.obligations.empty) {
      console.log("Obligations empty.");
      return;
    }
    const current_obligation = this.obligations.peek();
    send_to_peer(this.sockets.get(current_obligation!.player)!, "obligation", {
      obligation_type: current_obligation!.obligation_type,
      context: current_obligation!.context,
    });
  }

  process_obligation_response(
    data: {
      obligation_type: ObligationType;
      choice: unknown;
    },
    playerID: UUID
  ) {
    const current_obligation = this.obligations.peek();
    if (
      current_obligation == undefined ||
      current_obligation.obligation_type != data.obligation_type ||
      current_obligation.player != playerID
    )
      return;
    switch (data.obligation_type) {
    }
    this.obligations.pop();
    this.send_next_obligation();
  }

  broadcast() {
    this.players.forEach((player: Player) => {
      send_to_peer(this.sockets.get(player.id)!, "game_state", {
        game_state: this.get_sendable(player.id),
      });
    });
  }

  get_sendable(to_player?: UUID) {
    const { obligations, sockets, ...clone } = JSON.parse(
      JSON.stringify(this)
    ) as Game;
    if (to_player) {
      console.log(to_player);
      console.log(clone.players[0]);
      // clone.players
      //   .filter((player: Player) => player.id != to_player)
      //   .forEach((player: Player) => {
      //     // FIXME Replace in-hand coins with filler coins so the other players know how many are left in hand.
      //     player.units = player.units.filter(
      //       (unit: Unit) =>
      //         ![UnitState.In_Hand, UnitState.In_Bag].includes(unit.state)
      //     );
      //   });
    }
    return clone;
  }
}
