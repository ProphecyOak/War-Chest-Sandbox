import http, { IncomingMessage } from "http";

import express from "express";
import { Request, Response } from "express";
import { setup_HTTP_routes } from "./routes/http-routes";

import ws, { WebSocket } from "ws";
import { setup_WS_routes } from "./routes/ws-routes";
import { randomUUID, UUID } from "crypto";

const PORT_NUMBER = 3000;
const REGISTRY_URL = "http://wcpp-registry:3000";

// Retry logic for registry
async function registerWithRetry(name: string, url: string, maxRetries = 5) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const res = await fetch(`${REGISTRY_URL}/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, url }),
      });
      if (!res.ok) throw new Error(`Status ${res.status}`);
      console.log("Registered with registry");
      return;
    } catch (err) {
      console.log(
        `Failed to register (attempt ${i + 1}): ${(err as Error).message}`
      );
      await new Promise((r) => setTimeout(r, 1000 * (i + 1)));
    }
  }
  console.log("Could not register with registry. Exiting.");
  process.exit(1);
}

async function lookupService(name: string): Promise<string | null> {
  try {
    const res = await fetch(`${REGISTRY_URL}/lookup?name=${name}`);
    if (!res.ok) throw new Error(`Status ${res.status}`);
    const { url } = await res.json();
    return url;
  } catch (err) {
    console.log(`Lookup failed for ${name}: ${(err as Error).message}`);
    return null;
  }
}

const app = express();
setup_HTTP_routes(app, lookupService);
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

server.listen(PORT_NUMBER, () => {
  console.log(`Gateway service listening on port ${PORT_NUMBER}`);
  registerWithRetry("wcpp-gateway", `http://wcpp-gateway:${PORT_NUMBER}`);
});
