export { send_to_peer, error_to_peer };
import { WebSocket } from "ws";

function send_to_peer(ws: WebSocket, op_code: string, extras?: {}) {
  ws.send(JSON.stringify({ op: op_code, ...extras }));
}

function error_to_peer(
  ws: WebSocket,
  reason: string,
  original_request: { [key: string]: any },
  extras?: {}
) {
  send_to_peer(ws, "error", { reason, request: original_request, ...extras });
}
