import type { ActionFunctionArgs } from "react-router";
import { authenticate } from "../shopify.server";
import { purgeShopData } from "../db.server";

export const action = async ({ request }: ActionFunctionArgs) => {
  const { shop, topic } = await authenticate.webhook(request);

  console.log(`Received ${topic} webhook for ${shop}`);

  if (!shop) {
    return new Response("Missing shop on webhook payload", { status: 400 });
  }

  // This webhook can be delivered multiple times. deleteMany + transaction keeps
  // cleanup idempotent and removes all tenant data on uninstall.
  await purgeShopData(shop);

  return new Response();
};
