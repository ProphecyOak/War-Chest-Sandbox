import http, { IncomingMessage } from "http";

import express from "express";
import { Request, Response } from "express";
import { setup_HTTP_routes } from "./routes/http-routes";

import ws, { WebSocket } from "ws";
import { setup_WS_routes } from "./routes/ws-routes";

import * as WCPP from "wcpp-utils";

const app = express();
setup_HTTP_routes(app);
app.use(express.json());
const server = http.createServer(app);

const wss = new ws.Server({ server });

app.get("/", (req: Request, res: Response) => {
  res.send("Hello from the WCPP Gateway!");
});

const socket_peers: Record<string, WebSocket> = {};

wss.on("connection", async (ws: WebSocket, req: IncomingMessage) => {
  var supplied_id = req.headers.id;
  if (typeof supplied_id !== "string") {
    ws.close(1002, "ID invalid or missing.");
    return;
  }
  socket_peers[supplied_id] = ws;
  console.log(`WS client has connected with ${supplied_id}.`);
  await setup_WS_routes(ws, supplied_id as string, socket_peers);
});

process.on("SIGTERM", () => {
  console.log("Received SIGTERM signal. Initiating graceful shutdown...");
  Object.values(socket_peers).forEach((socket: WebSocket) => {
    socket.close(1001);
  });
  server.close(() => {
    process.exit(0);
  });
});

server.listen(WCPP.PORT_NUMBER, () => {
  console.log(`Gateway service listening on port ${WCPP.PORT_NUMBER}`);
  WCPP.registerWithRetry(
    "wcpp-gateway",
    `http://wcpp-gateway:${WCPP.PORT_NUMBER}`
  );
});
