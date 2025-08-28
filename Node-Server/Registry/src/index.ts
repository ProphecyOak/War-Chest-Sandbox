import express from "express";
import { Request, Response } from "express";

const PORT = 3000;

const app = express();
app.use(express.json());

const services: Record<string, string> = {};

app.post("/register", (req: Request, res: Response) => {
  const { name, url } = req.body;
  if (!name || !url) {
    return res.status(400).json({ error: "Missing name or url" });
  }
  services[name] = url;
  res.json({ status: "ok" });
});

app.get("/lookup", (req: Request, res: Response) => {
  const name = req.query.name as string;
  if (!name) {
    return res.status(400).json({ error: "Missing service name" });
  }
  const url = services[name];
  if (!url) {
    return res.status(404).json({ error: "Service not found" });
  }
  res.json({ url });
});

app.listen(PORT, () => {
  console.log(`Registry service listening on port ${PORT}`);
});
