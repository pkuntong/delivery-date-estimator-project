import type { MetaFunction } from "react-router";
import { Link } from "react-router";

export const meta: MetaFunction = () => [
  { title: "Terms of Service | Delivery Date Estimator" },
];

const containerStyle = {
  maxWidth: 880,
  margin: "0 auto",
  padding: "44px 24px",
  lineHeight: 1.7,
  color: "#111827",
  fontFamily:
    "Inter, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
};

export default function TermsOfServicePage() {
  return (
    <main style={containerStyle}>
      <h1>Terms of Service</h1>
      <p>
        Last updated: February 18, 2026
      </p>

      <h2>1. Service</h2>
      <p>
        Delivery Date Estimator is a Shopify app that provides delivery estimate
        and countdown functionality for merchant storefronts.
      </p>

      <h2>2. Merchant Responsibilities</h2>
      <p>
        Merchants are responsible for entering accurate shipping and operational
        settings. Delivery estimates are informational and depend on merchant
        fulfillment processes.
      </p>

      <h2>3. Billing</h2>
      <p>
        Paid plans are billed through Shopify according to the selected
        subscription. Plan features may change with notice.
      </p>

      <h2>4. Availability</h2>
      <p>
        We aim for high availability but do not guarantee uninterrupted service.
      </p>

      <h2>5. Liability</h2>
      <p>
        The service is provided on an "as is" basis. To the maximum extent
        permitted by law, liability is limited to the amount paid for the app in
        the prior 12 months.
      </p>

      <h2>6. Contact</h2>
      <p>
        For support or legal questions, contact{" "}
        <a href="mailto:support@deliverydateestimator.app">
          support@deliverydateestimator.app
        </a>
        .
      </p>

      <p>
        <Link to="/">Back to home</Link>
      </p>
    </main>
  );
}
