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
  try {
    AppDataSource.dropDatabase().finally(() => AppDataSource.destroy());
  } catch {}
  server.close(() => {
    process.exit(0);
  });
});

async function connect() {
  const { attempts } = await WCPP.retryFunction(async () =>
    AppDataSource.initialize()
      .then(() => ({
        status: 200,
        message: "Connected to database successfully.",
      }))
      .catch((error) => {
        return {
          status: 503,
          message: "Database connection failed.",
        };
      })
  );
  console.log(
    `Connected to database in ${attempts} ${attempts > 1 ? "tries" : "try"}.`
  );
  setup_HTTP_routes(app, AppDataSource);
  server.listen(WCPP.PORT_NUMBER, () => {
    console.log(`Database service listening on port ${WCPP.PORT_NUMBER}`);
    WCPP.registerWithRetry("wcpp-db", `http://wcpp-db:${WCPP.PORT_NUMBER}`);
  });
}

connect();
