import { data } from "react-router";
import db from "../db.server";

export async function loader() {
  const startedAt = Date.now();

  try {
    await db.$queryRaw`SELECT 1`;
    await db.session.findFirst({ select: { id: true } });
    await db.storeConfig.findFirst({ select: { id: true } });

    return data(
      {
        ok: true,
        database: "reachable",
        latencyMs: Date.now() - startedAt,
        commit: process.env.VERCEL_GIT_COMMIT_SHA ?? "unknown",
        timestamp: new Date().toISOString(),
      },
      {
        headers: {
          "Cache-Control": "no-store",
        },
      },
    );
  } catch {
    return data(
      {
        ok: false,
        database: "unreachable",
        latencyMs: Date.now() - startedAt,
        commit: process.env.VERCEL_GIT_COMMIT_SHA ?? "unknown",
        timestamp: new Date().toISOString(),
      },
      {
        status: 503,
        headers: {
          "Cache-Control": "no-store",
        },
      },
    );
  }
}
