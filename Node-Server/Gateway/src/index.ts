import http, { IncomingMessage } from "http";

import express from "express";
import { Request, Response } from "express";
import { setup_HTTP_routes } from "./routes/http-routes";

import ws, { WebSocket } from "ws";
import { setup_WS_routes } from "./routes/ws-routes";
import { randomUUID, UUID } from "crypto";

import * as WCPP from "wcpp-utils";

const app = express();
setup_HTTP_routes(app, WCPP.lookupService);
app.use(express.json());
const server = http.createServer(app);

const wss = new ws.Server({ server });

app.get("/", (req: Request, res: Response) => {
  res.send("Hello from the WCPP Gateway!");
});

wss.on("connection", (ws: WebSocket, req: IncomingMessage) => {
  console.log("WS client has connected.");
  var supplied_id = req.headers.uuid;
  var client_id: UUID;
  if (supplied_id == "null") client_id = randomUUID();
  else client_id = supplied_id as UUID;
  setup_WS_routes(ws, client_id);
});

process.on("SIGTERM", () => {
  console.log("Received SIGTERM signal. Initiating graceful shutdown...");
  // TODO: Implement logic to kill ongoing WSS connections.
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
