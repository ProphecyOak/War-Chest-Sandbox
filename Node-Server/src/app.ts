import { WebSocketServer, WebSocket, RawData } from "ws";
import { config } from "dotenv";
import { IncomingMessage } from "http";
import { randomUUID } from "crypto";

config();
const PORT_NUMBER = Number(process.env.PORT);

const wss = new WebSocketServer({
  port: PORT_NUMBER,
});

wss.on("listening", () => {
  console.log(`Server started on port: ${PORT_NUMBER}`);
});

let peers: Record<string, WebSocket> = {};

wss.on("connection", (ws: WebSocket, req: IncomingMessage) => {
  console.log(`Client connected.`);
  if (req.headers.uuid == "null") {
    const new_id = randomUUID();
    console.log(`Client given uuid: ${new_id}`);
    peers[new_id] = ws;
    ws.send(
      JSON.stringify({
        op: "assign_uuid",
        uuid: new_id,
      })
    );
  }

  ws.on("message", (data: RawData) => {
    console.log(data.toString());
  });
});
