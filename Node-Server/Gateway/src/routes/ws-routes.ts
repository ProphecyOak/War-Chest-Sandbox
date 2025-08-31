import { RawData, WebSocket } from "ws";
import { Response, Request } from "express";
import * as WCPP from "wcpp-utils";

export async function setup_WS_routes(
  ws: WebSocket,
  client_id: string,
  socket_peers: Record<string, WebSocket>
) {
  const get_db_url = await WCPP.get_url_factory("wcpp-db");
  const db_url = await get_db_url();
  const id_check_result = await fetch(`${db_url}/player?id=${client_id}`);
  if (id_check_result.status == 400) {
    ws.close(
      4401,
      "Unauthorized Connection Attempt: ID not found in database."
    );
  }

  ws.on("message", (packet: RawData) => {
    const data = JSON.parse(packet.toString());
    console.log(
      `Received message from ${client_id} containing this data: ${JSON.stringify(
        data
      )}`
    );
  });
  ws.on("close", () => {
    console.log("WS client has disconnected.");
    delete socket_peers[client_id];
  });
}
