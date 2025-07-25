import { WebSocketServer, WebSocket, RawData } from "ws";
import { config } from "dotenv";
import { IncomingMessage } from "http";
import { randomUUID, UUID } from "crypto";
import { Room } from "./room";
import { error_to_peer, send_to_peer } from "./server_tools";

config();

const PORT_NUMBER = Number(process.env.PORT);
const wss = new WebSocketServer({
  port: PORT_NUMBER,
});
wss.on("listening", () => {
  console.log(`Server started on port: ${PORT_NUMBER}`);
});

let peers: Map<UUID, WebSocket> = new Map<UUID, WebSocket>();
let peerRooms: Map<UUID, Room> = new Map<UUID, Room>();

wss.on("connection", (ws: WebSocket, req: IncomingMessage) => {
  console.log(`Client connected.`);
  var supplied_id = req.headers.uuid;
  var peer_id: UUID;
  if (supplied_id == "null") peer_id = assign_UUID(ws);
  else peer_id = supplied_id as UUID;
  peers.set(peer_id, ws);

  ws.on("message", (packet: RawData) => {
    const data = JSON.parse(packet.toString());
    resolve_incoming_message(peer_id, data as WSData);
  });

  ws.on("close", () => {
    if (peerRooms.has(peer_id)) leave_room(peer_id);
    peers.delete(peer_id);
    console.log(`Client ${peer_id} has disconnected.`);
  });
});

function assign_UUID(ws: WebSocket) {
  const new_id: UUID = randomUUID();
  console.log(`Client given uuid: ${new_id}`);
  send_to_peer(ws, "assign_uuid", { uuid: new_id });
  return new_id;
}

interface WSData {
  op: string;
  [key: string]: any;
}

function resolve_incoming_message(peer_id: UUID, data: WSData) {
  const ws = peers.get(peer_id)!;
  const room: Room | undefined = peerRooms.get(peer_id);
  switch (data.op) {
    case "create_room":
      // Client is asking to create a new room and join it.
      // HAS null
      // RES room_id
      const new_room = new Room(peer_id, ws);
      peerRooms.set(peer_id, new_room);
      send_to_peer(ws, "room_created", {
        room_id: new_room.id,
      });
      return;

    case "join_room":
      // Client is asking to join an existing room.
      // HAS room_id
      // RES null
      if (any_missing(ws, data, ["room_id"])) return false;
      if (!Room.rooms.has(data.room_id)) {
        error_to_peer(ws, "invalid_room_id", data);
        return;
      }
      const room_to_join = Room.rooms.get(data.room_id)!;
      room_to_join.add_peer(peer_id, ws);
      peerRooms.set(peer_id, room_to_join);
      send_to_peer(ws, "joined_room", { room_id: data.room_id });
      return;

    case "leave_room":
      // Client is asking to leave the room they are in.
      leave_room(peer_id);
      return;

    case "push_game_settings":
      // Client is selecting and providing the board arrangement, and other settings for their room.
      // HAS board
      // HAS draft_type
      // HAS unit_list
      // BROADCAST game_settings_updated
      if (any_missing(ws, data, ["board"])) return false;
      if (room == undefined) return false;
      if (!room.game.set_board(data.board))
        error_to_peer(ws, "invalid_board_submitted", data);
      else room.broadcast("game_settings_updated");
      return;

    case "pull_game_settings":
      // Client is asking for pre-game settings.
      // HAS null
      // RES game_settings
      if (room == undefined) return false;
      send_to_peer(ws, "supply_game_settings", {
        game_state: room.game.get_sendable(),
      });
      return;

    case "start_game":
      // Client (host) is asking to start the game.
      if (room == undefined || room.host != peer_id || !room.game.has_board)
        return false;
      room.game.set_players(room.players);
      room.broadcast("image_list", { images: room.images }, peer_id);
      room.broadcast("game_started", {
        game_state: room.game.get_sendable(),
      });
      room.game.start_draft();
      return;

    case "pull_game_state":
      // Client is asking for current game state.
      // HAS null
      // RES game_state
      if (room == undefined || !room.game.has_board) return false;
      send_to_peer(ws, "game_state", room.game.get_sendable(peer_id));
      return;

    case "obligation_response":
      // Client is responding to obligation.
      // HAS response
      // RES obligation
      if (any_missing(ws, data, ["answer"])) return false;
      if (room == undefined || !room.game.has_board) return false;
      room.game.process_obligation_response(data.answer, peer_id);
      return;

    case "push_image":
      // Client (host) is providing an image it has.
      // HAS image_string
      // HAS image_id
      // RES null
      if (room == undefined || room.host != peer_id) return false;
      room.images.units[data.image_id!] = data.image_string!;
      return;

    case "push_move":
    // Client is submitting a move
    // HAS move (Datatype undecided so far)
    // BROADCAST pull_game

    case "push_unit_choice":
    // Client is choosing a unit.
    // HAS unit_id
    // BROADCAST unit_choices OR
    // BROADCAST game_start

    case "push_game_choice":
    // Client is choosing the outcome of an undo-request or a coin effect (i.e. Royal Guard).
    // HAS decision_id
    // HAS decision
    // BROADCAST pull_game

    default:
      console.log(`Unhandled message op: ${data.op} from:\n\t${peer_id}`);
      return;
  }
}

function leave_room(peer_id: UUID) {
  peerRooms.get(peer_id)!.remove_peer(peer_id);
  peerRooms.delete(peer_id);
  console.log(`Client ${peer_id} has left their room.`);
}

function any_missing(
  ws: WebSocket,
  data: { [key: string]: any },
  keys: string[]
) {
  const missing_keys: string[] = [];
  keys.forEach((key: string) => {
    if (data[key] == undefined) missing_keys.push(key);
  });
  if (missing_keys.length > 0)
    error_to_peer(ws, "message_missing_data", data, {
      missing_keys: missing_keys,
    });
  return false;
}
