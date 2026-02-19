import type { LoaderFunctionArgs } from "react-router";
import { data } from "react-router";
import db from "../db.server";
import { authenticate } from "../shopify.server";

export async function loader({ request }: LoaderFunctionArgs) {
  const startedAt = Date.now();
  await authenticate.admin(request);

  try {
    await db.$queryRaw`SELECT 1`;

    return data({
      ok: true,
      database: "reachable",
      latencyMs: Date.now() - startedAt,
      timestamp: new Date().toISOString(),
    });
  } catch {
    return data(
      {
        ok: false,
        database: "unreachable",
        latencyMs: Date.now() - startedAt,
        timestamp: new Date().toISOString(),
      },
      { status: 500 },
    );
  }
}
