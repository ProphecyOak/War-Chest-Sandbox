import { WebSocketServer, WebSocket, RawData } from "ws";
import { config } from "dotenv";

config();
const PORT_NUMBER = Number(process.env.PORT);

const wss = new WebSocketServer({
  port: PORT_NUMBER,
});

wss.on("listening", () => {
  console.log(`Server started on port: ${PORT_NUMBER}`);
});

wss.on("connection", (ws: WebSocket) => {
  console.log("Client connected.");
  ws.on("message", (data: RawData) => {
    console.log(data.toString());
  });
});
