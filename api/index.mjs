import * as build from "../delivery-date-estimator/build/server/index.js";
import { createRequestListener } from "../delivery-date-estimator/node_modules/@react-router/node/dist/index.mjs";

const requestListener = createRequestListener({
  build,
  mode: process.env.NODE_ENV || "production",
});

export default function handler(req, res) {
  return requestListener(req, res);
}
