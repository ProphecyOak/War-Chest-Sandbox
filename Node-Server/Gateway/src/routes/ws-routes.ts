import { RawData, WebSocket } from "ws";
import { Response, Request } from "express";
import * as WCPP from "wcpp-utils";
import {
  MessageCallback,
  IWebSocketMessage,
  setup_WS_bindings,
} from "./ws-callbacks";

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
  socket_peers[client_id] = ws;
  const callbacks: Record<string, MessageCallback[]> = {};

  function bind(event_name: string, callback: MessageCallback) {
    callbacks[event_name] = callbacks[event_name] || [];
    callbacks[event_name].push(callback);
  }
  function send(
    message: IWebSocketMessage,
    recipients: WebSocket[] | WebSocket
  ) {
    if (!Array.isArray(recipients)) recipients = [recipients];
    recipients.forEach((client: WebSocket) => {
      client.send(JSON.stringify(message));
    });
  }

  setup_WS_bindings(bind, send);

  ws.on("message", (packet: RawData) => {
    const message = JSON.parse(packet.toString()) as IWebSocketMessage;
    const relevantCallbacks = callbacks[message.event_name] || [];
    if (relevantCallbacks.length == 0) {
      console.log(`Unhandled event of type: '${message.event_name}'`);
      send(
        { event_name: "unhandled_event", event_data: { received: message } },
        [ws]
      );
      return;
    }
    relevantCallbacks.forEach((callback: MessageCallback) =>
      callback(message, ws)
    );
  });

  ws.on("close", () => {
    console.log("WS client has disconnected.");
    delete socket_peers[client_id];
  });
}
