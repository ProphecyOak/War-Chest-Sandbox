export { send_to_peer };
import { WebSocket } from "ws";

function send_to_peer(ws: WebSocket, op_code: string, extras?: {}) {
  ws.send(JSON.stringify({ op: op_code, ...extras }));
}
