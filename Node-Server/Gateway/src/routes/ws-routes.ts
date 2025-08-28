import { RawData, WebSocket } from "ws";
import { randomUUID, UUID } from "crypto";
import { IncomingMessage } from "http";

export function setup_WS_routes(ws: WebSocket, uuid: UUID) {
  ws.on("message", (packet: RawData) => {
    const data = JSON.parse(packet.toString());
    console.log(`Received message containing this data: ${data}`);
  });
  ws.on("close", () => {
    console.log("WS client has disconnected.");
  });
}
