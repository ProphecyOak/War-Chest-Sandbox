import http from "http";
import express from "express";

import * as WCPP from "wcpp-utils";

const app = express();
app.use(express.json());
const server = http.createServer(app);

process.on("SIGTERM", () => {
  console.log("Received SIGTERM signal. Initiating graceful shutdown...");
  server.close(() => {
    process.exit(0);
  });
});

server.listen(WCPP.PORT_NUMBER, () => {
  console.log(`Logic service listening on port ${WCPP.PORT_NUMBER}`);
  WCPP.registerWithRetry("wcpp-logic", `http://wcpp-logic:${WCPP.PORT_NUMBER}`);
});
