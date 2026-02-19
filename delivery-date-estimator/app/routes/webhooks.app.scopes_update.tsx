import type { ActionFunctionArgs } from "react-router";
import { authenticate } from "../shopify.server";
import db from "../db.server";

export const action = async ({ request }: ActionFunctionArgs) => {
  const { payload, topic, shop } = await authenticate.webhook(request);
  console.log(`Received ${topic} webhook for ${shop}`);

  if (!shop) {
    return new Response("Missing shop on webhook payload", { status: 400 });
  }

  const currentScopes = Array.isArray((payload as { current?: unknown }).current)
    ? ((payload as { current: unknown[] }).current.filter(
        (scope): scope is string => typeof scope === "string",
      ))
    : [];

  await db.session.updateMany({
    where: { shop },
    data: {
      scope: currentScopes.join(","),
    },
  });

  return new Response();
};
