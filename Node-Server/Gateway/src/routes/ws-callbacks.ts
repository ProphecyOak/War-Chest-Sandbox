import WebSocket from "ws";

export type IWebSocketMessage = {
  event_name: string;
  event_data: Object;
};
export type MessageCallback = (
  message: IWebSocketMessage,
  ws_origin: WebSocket
) => void;

export function setup_WS_bindings(
  bind: (event_name: string, callback: MessageCallback) => void,
  send: (
    message: IWebSocketMessage,
    recipients: WebSocket[] | WebSocket
  ) => void
) {
  bind("start_game", (message, ws) => {
    send({ event_name: "game_started", event_data: {} }, ws);
  });
}
