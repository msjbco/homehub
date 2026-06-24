import Fastify from "fastify";
import { registerHealthRoutes } from "./routes/health.js";

export function buildApp() {
  const app = Fastify({
    logger: {
      level: process.env.LOG_LEVEL ?? "info"
    }
  });

  app.register(registerHealthRoutes);

  return app;
}
