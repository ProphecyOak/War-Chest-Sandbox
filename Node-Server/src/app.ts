import { WebSocketServer, WebSocket, RawData } from "ws";
import { config } from "dotenv";
import { IncomingMessage } from "http";
import { randomUUID, UUID } from "crypto";
import { Room } from "./room";

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
  var peer_id = req.headers.uuid;
  if (peer_id == "null") peer_id = assign_UUID(ws);
  peers.set(peer_id as UUID, ws);

  ws.on("message", (packet: RawData) => {
    const data = JSON.parse(packet.toString());
    resolve_incoming_message(peer_id as UUID, data as WSData);
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

function send_to_peer(ws: WebSocket, op_code: string, extras?: {}) {
  ws.send(JSON.stringify({ op: op_code, ...extras }));
}

function resolve_incoming_message(peer_id: UUID, data: WSData) {
  const ws = peers.get(peer_id)!;
  switch (data.op) {
    case "create_room":
      // Client is asking to create a new room and join it.
      // HAS null
      // RES room_id
      const new_room = new Room(peer_id);
      peerRooms.set(peer_id, new_room);
      send_to_peer(ws, "room_created", {
        room_id: new_room.id,
      });
      return;

    case "join_room":
      // Client is asking to join an existing room.
      // HAS room_id
      // RES null
      if (any_missing(ws, data, ["room_id"])) return;
      if (!Room.rooms.has(data.room_id)) {
        send_to_peer(ws, "error", {
          original_op: "join_room",
          error_code: "invalid_room_id",
        });
        return;
      }
      Room.rooms.get(data.room_id as UUID)!.add_peer(peer_id);
      send_to_peer(ws, "joined_room", { room_id: data.room_id });
      return;

    case "push_game_settings":
      // Client is selecting and providing the board arrangement, and other settings for their room.
      // HAS board
      // HAS draft_type
      // HAS unit_list
      // BROADCAST pull_game_settings
      return;

    case "pull_game_settings":
      // Client is asking for pre-game settings.
      // HAS null
      // RES game_settings
      return;

    case "pull_game_state":
      // Client is asking for current game state.
      // HAS null
      // RES game_state
      return;

    case "push_move":
      // Client is submitting a move
      // HAS move (Datatype undecided so far)
      // BROADCAST pull_game
      return;

    case "push_unit_choice":
      // Client is choosing a unit.
      // HAS unit_id
      // BROADCAST unit_choices OR
      // BROADCAST game_start
      return;

    case "push_game_choice":
      // Client is choosing the outcome of an undo-request or a coin effect (i.e. Royal Guard).
      // HAS decision_id
      // HAS decision
      // BROADCAST pull_game
      return;

    case "push_image":
      // Client is providing an image it's been asked for.
      // HAS image_string
      // HAS image_id
      // RES null
      return;
  }
}

function any_missing(
  ws: WebSocket,
  data: { [key: string]: any },
  keys: string[]
) {
  keys.forEach((key: string) => {
    if (data[key] != undefined) return;
    send_to_peer(ws, "error", {
      missing_key: key,
    });
  });
  return false;
}
