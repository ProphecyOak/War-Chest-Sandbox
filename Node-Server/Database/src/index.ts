import "reflect-metadata";
import { AppDataSource } from "./data-source";

import http from "http";
import express from "express";
import { setup_HTTP_routes } from "./routes/http-routes";

import * as WCPP from "wcpp-utils";

const app = express();
app.use(express.json());
const server = http.createServer(app);

process.on("SIGTERM", async () => {
  console.log("Received SIGTERM signal. Initiating graceful shutdown...");
  if (AppDataSource.isInitialized) {
    await AppDataSource.dropDatabase().finally(() => AppDataSource.destroy());
  }
  server.close(() => {
    process.exit(0);
  });
});

AppDataSource.initialize()
  .then(() => {
    setup_HTTP_routes(app, AppDataSource);
    server.listen(WCPP.PORT_NUMBER, () => {
      console.log(`Database service listening on port ${WCPP.PORT_NUMBER}`);
      WCPP.registerWithRetry("wcpp-db", `http://wcpp-db:${WCPP.PORT_NUMBER}`);
    });
  })
  .catch((error) => console.log(error));
